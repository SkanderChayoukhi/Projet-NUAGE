resource "google_container_cluster" "primary" {
  name     = var.gke_cluster_name
  location = var.gcp_zone

  # Required by the course instructions.
  deletion_protection = true

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
    machine_type = "e2-medium"
    oauth_scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }
}
