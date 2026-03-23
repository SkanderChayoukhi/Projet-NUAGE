resource "docker_image" "this" {
  name = var.image_name

  build {
    context = "${var.project_root}/worker"
  }
}

resource "docker_container" "this" {
  image   = docker_image.this.image_id
  name    = var.container_name
  restart = "unless-stopped"

  networks_advanced {
    name = var.back_network_name
  }
}
