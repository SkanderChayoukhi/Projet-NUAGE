locals {
  raw_manifest_map = {
    for rel_path in var.manifest_files :
    rel_path => yamldecode(file("${path.root}/../${rel_path}"))
    if rel_path != "k8s/redis-service.yaml" && !(var.enable_redis_vm && rel_path == "k8s/redis-deployment.yaml")
  }

  manifest_map = {
    for rel_path, manifest in local.raw_manifest_map :
    rel_path => merge(
      manifest,
      {
        metadata = merge(
          lookup(manifest, "metadata", {}),
          { namespace = var.k8s_namespace }
        )
      },
      rel_path == "k8s/app-configmap.yaml" ? {
        data = merge(
          lookup(manifest, "data", {}),
          {
            POSTGRES_PASSWORD = var.postgres_password
          },
          var.enable_redis_vm ? {
            REDIS_HOST     = "redis"
            REDIS_PASSWORD = var.redis_password
          } : {}
        )
      } : {},
    )
  }

  redis_service_manifest = merge(
    yamldecode(file("${path.root}/../k8s/redis-service.yaml")),
    {
      metadata = merge(
        lookup(yamldecode(file("${path.root}/../k8s/redis-service.yaml")), "metadata", {}),
        { namespace = var.k8s_namespace }
      )
    },
    var.enable_redis_vm ? {
      spec = merge(
        lookup(yamldecode(file("${path.root}/../k8s/redis-service.yaml")), "spec", {}),
        {
          clusterIP = "None"
          selector  = null
        }
      )
    } : {}
  )
}

resource "terraform_data" "redis_service_mode" {
  input = var.enable_redis_vm ? "external-vm" : "in-cluster"
}

resource "kubernetes_manifest" "app" {
  for_each = local.manifest_map

  manifest = each.value

  # Jobs get controller labels injected by Kubernetes after creation.
  # Mark these fields as computed to avoid provider inconsistency errors.
  computed_fields = concat(
    [
      "metadata.labels",
      "spec.template.metadata.labels",
    ],
    each.key == "k8s/vote-deployment.yaml" ? ["spec.replicas"] : []
  )

  depends_on = [google_container_node_pool.primary]
}

resource "kubernetes_manifest" "redis_service" {
  manifest = local.redis_service_manifest

  lifecycle {
    replace_triggered_by = [terraform_data.redis_service_mode]
  }

  depends_on = [google_container_node_pool.primary]
}

resource "kubernetes_manifest" "redis_endpoints" {
  count = var.enable_redis_vm ? 1 : 0

  manifest = {
    apiVersion = "v1"
    kind       = "Endpoints"
    metadata = {
      name      = "redis"
      namespace = var.k8s_namespace
      labels = {
        app = "redis"
      }
    }
    subsets = [
      {
        addresses = [
          {
            ip = google_compute_instance.redis_vm[0].network_interface[0].network_ip
          }
        ]
        ports = [
          {
            name     = "redis"
            port     = 6379
            protocol = "TCP"
          }
        ]
      }
    ]
  }

  depends_on = [google_container_node_pool.primary, kubernetes_manifest.app, kubernetes_manifest.redis_service]
}
