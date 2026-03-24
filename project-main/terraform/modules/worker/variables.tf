variable "image_name" {
  type = string
}

variable "push_image" {
  type    = bool
  default = false
}

variable "container_name" {
  type = string
}

variable "project_root" {
  type = string
}

variable "back_network_name" {
  type = string
}
