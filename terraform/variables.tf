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