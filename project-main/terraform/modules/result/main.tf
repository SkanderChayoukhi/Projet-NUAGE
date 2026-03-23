resource "docker_image" "this" {
  name = var.image_name

  build {
    context = "${var.project_root}/result"
  }
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
