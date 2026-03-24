variable "image_vote" {
  description = "Image name for vote service"
  type        = string
  default     = "europe-west3-docker.pkg.dev/tuto-devops-490710/voting-image/vote:latest"
}

variable "image_result" {
  description = "Image name for result service"
  type        = string
  default     = "europe-west3-docker.pkg.dev/tuto-devops-490710/voting-image/result:latest"
}

variable "image_worker" {
  description = "Image name for worker service"
  type        = string
  default     = "europe-west3-docker.pkg.dev/tuto-devops-490710/voting-image/worker:latest"
}

variable "image_seed" {
  description = "Image name for seed service"
  type        = string
  default     = "europe-west3-docker.pkg.dev/tuto-devops-490710/voting-image/seed-data:latest"
}

variable "image_nginx" {
  description = "Image name for nginx service"
  type        = string
  default     = "europe-west3-docker.pkg.dev/tuto-devops-490710/voting-image/nginx:latest"
}

variable "push_to_registry" {
  description = "When true, push locally built images to their configured registry"
  type        = bool
  default     = false
}

variable "postgres_user" {
  description = "Postgres username"
  type        = string
  default     = "postgres"
}

variable "postgres_password" {
  description = "Postgres password"
  type        = string
  default     = "postgres"
  sensitive   = true
}

variable "postgres_db" {
  description = "Postgres database name"
  type        = string
  default     = "postgres"
}
