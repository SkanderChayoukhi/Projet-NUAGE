data "archive_file" "source_hash" {
  type        = "zip"
  source_dir  = "${var.project_root}/vote"
  output_path = "${path.module}/.vote-src.zip"
}

resource "docker_image" "this" {
  name = var.image_name

  triggers = {
    source_hash = data.archive_file.source_hash.output_sha
  }

  build {
    context = "${var.project_root}/vote"
  }
}

resource "docker_registry_image" "this" {
  count = var.push_image ? 1 : 0
  name  = docker_image.this.name
}

resource "docker_container" "this" {
  image   = docker_image.this.image_id
  name    = var.container_name
  restart = "unless-stopped"

  networks_advanced {
    name = var.front_network_name
  }

  networks_advanced {
    name = var.back_network_name
  }

  healthcheck {
    test         = ["CMD", "curl", "-f", "http://localhost:5000"]
    interval     = "15s"
    timeout      = "5s"
    retries      = 3
    start_period = "10s"
  }
}
