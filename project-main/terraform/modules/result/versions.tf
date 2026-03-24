terraform {
  required_providers {
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.5"
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}
