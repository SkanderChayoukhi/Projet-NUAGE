locals {
  raw_manifest_map = {
    for rel_path in var.manifest_files :
    rel_path => yamldecode(file("${path.root}/../${rel_path}"))
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
      }
    )
  }
}

resource "kubernetes_manifest" "app" {
  for_each = local.manifest_map

  manifest = each.value

  # Jobs get controller labels injected by Kubernetes after creation.
  # Mark these fields as computed to avoid provider inconsistency errors.
  computed_fields = [
    "metadata.labels",
    "spec.template.metadata.labels",
  ]

  depends_on = [google_container_node_pool.primary]
}
