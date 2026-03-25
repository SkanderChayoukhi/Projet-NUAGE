resource "google_compute_instance" "redis_vm" {
  count        = var.enable_redis_vm ? 1 : 0
  name         = var.redis_vm_name
  machine_type = var.redis_vm_machine_type
  zone         = var.gcp_zone

  boot_disk {
    initialize_params {
      image = var.redis_vm_image
    }
  }

  network_interface {
    network = "default"

    # Keep an external IP so startup can install packages without additional NAT setup.
    access_config {}
  }

  metadata_startup_script = <<-EOT
    #!/usr/bin/env bash
    set -euo pipefail

    DEBIAN_FRONTEND=noninteractive apt update -q
    DEBIAN_FRONTEND=noninteractive apt install -q -y redis-server

    sed -e '/^bind/s/bind.*/bind 0.0.0.0/' -i /etc/redis/redis.conf
    sed -e '/# requirepass/s/.*/requirepass ${var.redis_password}/' -i /etc/redis/redis.conf

    systemctl restart redis-server
    systemctl enable redis-server
  EOT

  tags = ["redis"]
}

# Allow GKE cluster nodes to reach Redis VM on port 6379
resource "google_compute_firewall" "allow_gke_to_redis" {
  count       = var.enable_redis_vm ? 1 : 0
  name        = "allow-gke-to-redis-vm"
  network     = "default"
  direction   = "INGRESS"
  priority    = 1000
  target_tags = ["redis"]

  source_ranges = [
    # GKE cluster pods use the cluster's subnet
    google_container_cluster.primary.cluster_ipv4_cidr
  ]

  allow {
    protocol = "tcp"
    ports    = ["6379"]
  }
}
