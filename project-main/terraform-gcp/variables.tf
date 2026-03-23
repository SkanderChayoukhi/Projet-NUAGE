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
    "k8s/redis-configmap.yaml",
    "k8s/redis-deployment.yaml",
    "k8s/redis-service.yaml",
    "k8s/vote-deployment.yaml",
    "k8s/vote-service.yaml",
    "k8s/result-deployment.yaml",
    "k8s/result-service.yaml",
    "k8s/worker-deployment.yaml",
    "k8s/seed-job.yaml"
  ]
}

variable "k8s_namespace" {
  description = "Namespace used for all namespaced Kubernetes resources"
  type        = string
  default     = "default"
}
