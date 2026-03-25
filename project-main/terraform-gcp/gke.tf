resource "google_container_cluster" "primary" {
  name     = var.gke_cluster_name
  location = var.gcp_zone

  # Keep false so `terraform destroy` can remove the cluster without manual state edits.
  deletion_protection = false

  remove_default_node_pool = true
  initial_node_count       = 1

  network    = "default"
  subnetwork = "default"
}

resource "google_container_node_pool" "primary" {
  name       = "primary-pool"
  location   = var.gcp_zone
  cluster    = google_container_cluster.primary.name
  node_count = var.gke_node_count

  node_config {
    machine_type = "n2-standard-2"
    oauth_scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }
}
