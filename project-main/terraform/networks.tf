resource "docker_network" "front_net" {
  name = "front-net"
}

resource "docker_network" "back_net" {
  name = "back-net"
}
