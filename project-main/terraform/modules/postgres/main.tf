resource "docker_image" "this" {
  name = "postgres:15-alpine"
}

resource "docker_container" "this" {
  image   = docker_image.this.image_id
  name    = var.container_name
  restart = "unless-stopped"

  env = [
    "POSTGRES_USER=${var.postgres_user}",
    "POSTGRES_PASSWORD=${var.postgres_password}",
    "POSTGRES_DB=${var.postgres_db}",
  ]

  networks_advanced {
    name = var.network_name
  }

  mounts {
    target = "/var/lib/postgresql/data"
    source = var.volume_name
    type   = "volume"
  }

  healthcheck {
    test         = ["CMD-SHELL", "pg_isready -U ${var.postgres_user} -d ${var.postgres_db}"]
    interval     = "15s"
    timeout      = "5s"
    retries      = 3
    start_period = "10s"
  }
}
