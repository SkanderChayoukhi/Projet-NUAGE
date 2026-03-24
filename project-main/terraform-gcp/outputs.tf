output "gke_cluster_name" {
  value = google_container_cluster.primary.name
}

output "gke_cluster_location" {
  value = google_container_cluster.primary.location
}

output "gke_cluster_endpoint" {
  value = google_container_cluster.primary.endpoint
}

output "applied_manifest_files" {
  value = keys(kubernetes_manifest.app)
}

output "redis_vm_internal_ip" {
  value = var.enable_redis_vm ? google_compute_instance.redis_vm[0].network_interface[0].network_ip : null
}
