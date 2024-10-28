variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The GCP region"
  type        = string
}

variable "bucket" {
  description = "The GCS bucket name for the backend"
  type        = string
}

variable "gke_cluster_name" {
  description = "The name of the GKE cluster"
  type        = string
}

variable "gke_cluster_zones" {
  description = "The zones in which the GKE cluster will be created"
  type        = list(string)
  default = ["us-central1-a", "us-central1-b", "us-central1-c"]
}

variable "grafana_admin_user" {
  description = "The admin user for Grafana"
  type        = string
  default     = "admin"
}

variable "grafana_admin_password" {
  description = "The admin password for Grafana"
  type        = string
  default     = "adminPassword"
}

variable "polygon_api_key" {
  description = "value of the polygon api key"
  type        = string
  sensitive   = true
}

variable "cluster_issuer_email" {
  description = "The email address for the cluster issuer"
  type        = string
}

variable "cluster_issuer_name" {
  description = "The name of the cluster issuer"
  type        = string
  default     = "cert-manager-global"
}

variable "cluster_issuer_private_key_secret_name" {
  description = "The name of the secret for the cluster issuer private key"
  type        = string
  default     = "cert-manager-private-key"
}