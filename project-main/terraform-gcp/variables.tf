variable "gcp_project_id" {
  description = "GCP project ID"
  type        = string
}

variable "gcp_region" {
  description = "GCP region for provider"
  type        = string
  default     = "europe-west3"
}

variable "gcp_zone" {
  description = "GCP zone used for the GKE cluster location"
  type        = string
  default     = "europe-west3-a"
}

variable "gke_cluster_name" {
  description = "GKE cluster name"
  type        = string
  default     = "voting-app-cluster"
}

variable "gke_node_count" {
  description = "Number of nodes in the GKE node pool (mandatory: 1)"
  type        = number
  default     = 1
}

variable "manifest_files" {
  description = "Mandatory Kubernetes manifests to apply with kubernetes_manifest"
  type        = list(string)
  default = [
    "k8s/app-configmap.yaml",
    "k8s/db-pvc.yaml",
    "k8s/db-service.yaml",
    "k8s/db-deployment.yaml",
    "k8s/redis-deployment.yaml",
    "k8s/redis-service.yaml",
    "k8s/vote-deployment.yaml",
    "k8s/vote-service.yaml",
    "k8s/vote-hpa.yaml",
    "k8s/result-deployment.yaml",
    "k8s/result-service.yaml",
    "k8s/worker-deployment.yaml",
    "k8s/seed-job.yaml"
  ]
}

variable "postgres_password" {
  description = "PostgreSQL password propagated to Kubernetes app configuration"
  type        = string
  default     = "postgres"
  sensitive   = true
}

variable "k8s_namespace" {
  description = "Namespace used for all namespaced Kubernetes resources"
  type        = string
  default     = "default"
}

variable "enable_redis_vm" {
  description = "Enable optional Part 3: deploy Redis on a standalone VM and wire Kubernetes to it"
  type        = bool
  default     = false
}

variable "redis_password" {
  description = "Redis password used by the standalone VM and application components"
  type        = string
  default     = "toto"
  sensitive   = true
}

variable "redis_vm_name" {
  description = "Name of the optional standalone Redis VM"
  type        = string
  default     = "redis-vm"
}

variable "redis_vm_machine_type" {
  description = "Machine type for the optional standalone Redis VM"
  type        = string
  default     = "e2-micro"
}

variable "redis_vm_image" {
  description = "Boot image for the optional standalone Redis VM"
  type        = string
  default     = "debian-cloud/debian-12"
}
