data "archive_file" "source_hash" {
  type        = "zip"
  source_dir  = "${var.project_root}/result"
  output_path = "${path.module}/.result-src.zip"
}

resource "docker_image" "this" {
  name = var.image_name

  triggers = {
    source_hash = data.archive_file.source_hash.output_sha
  }

  build {
    context = "${var.project_root}/result"
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

  env = ["PORT=4000"]

  ports {
    internal = 4000
    external = 4000
    protocol = "tcp"
  }

  networks_advanced {
    name = var.front_network_name
  }

  networks_advanced {
    name = var.back_network_name
  }
}
