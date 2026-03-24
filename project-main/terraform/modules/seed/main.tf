data "archive_file" "source_hash" {
  type        = "zip"
  source_dir  = "${var.project_root}/seed-data"
  output_path = "${path.module}/.seed-src.zip"
}

resource "docker_image" "this" {
  name = var.image_name

  triggers = {
    source_hash = data.archive_file.source_hash.output_sha
  }

  build {
    context = "${var.project_root}/seed-data"
  }
}

resource "docker_registry_image" "this" {
  count = var.push_image ? 1 : 0
  name  = docker_image.this.name
}

resource "docker_container" "this" {
  image = docker_image.this.image_id
  name  = var.container_name

  restart = "no"

  networks_advanced {
    name = var.front_network_name
  }
}
