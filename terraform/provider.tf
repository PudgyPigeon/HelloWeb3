locals {
  project_id = var.project_id
  region     = var.region
  bucket     = var.bucket
  default_labels = {
    managed-by = "terraform"
  }
}

terraform {
  required_version = "~> 1.5"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.2"
    }

    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.0.0"
    }

    kubernetes = {
        version = ">= 2.0.0"
        source = "hashicorp/kubernetes"
    }
    
    kubectl = {
      source = "gavinbunney/kubectl"
      version = "1.14.0"
    }
  }


  # backend "gcs" {
  #   # Rest of backend config for buckets is specified in backend.tf and backend-config input flag in terraform init command of
  #   # deployment script
  # }
}


provider "google" {
  project = local.project_id
  region  = local.region
}

provider "google-beta" {
  project = local.project_id
  region  = local.region
}

data "google_project" "this" {}

data "google_compute_default_service_account" "default" {}
