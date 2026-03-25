resource "docker_image" "this" {
  name = "redis:alpine"
}

resource "docker_container" "this" {
  image   = docker_image.this.image_id
  name    = var.container_name
  restart = "unless-stopped"

  networks_advanced {
    name = var.network_name
  }

  healthcheck {
    test         = ["CMD", "redis-cli", "ping"]
    interval     = "15s"
    timeout      = "5s"
    retries      = 3
    start_period = "10s"
  }
}
