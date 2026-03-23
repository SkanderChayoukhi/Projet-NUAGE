resource "docker_image" "this" {
  name = var.image_name

  build {
    context = "${var.project_root}/seed-data"
  }
}

resource "docker_container" "this" {
  image = docker_image.this.image_id
  name  = var.container_name

  restart = "no"

  networks_advanced {
    name = var.front_network_name
  }
}
