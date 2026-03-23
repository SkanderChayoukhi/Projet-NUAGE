resource "docker_image" "this" {
  name = var.image_name

  build {
    context = "${var.project_root}/nginx"
  }
}

resource "docker_container" "this" {
  image   = docker_image.this.image_id
  name    = var.container_name
  restart = "unless-stopped"

  ports {
    internal = 8000
    external = 8000
    protocol = "tcp"
  }

  networks_advanced {
    name = var.front_network_name
  }
}
