data "google_client_config" "default" {}

provider "kubernetes" {
  host                   = "https://${module.gke.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke.ca_certificate)
}

# Create a GKE cluster
module "gke" {
  source              = "terraform-google-modules/kubernetes-engine/google"
  cluster_name        = var.gke_cluster_name
  project_id          = var.project_id
  region              = var.region
  zones               = var.gke_cluster_zones 
  network             = google_compute_network.gke_vpc_1.self_link
  subnetwork          = google_compute_subnetwork.subnet_1.self_link
  ip_range_pods       = google_compute_subnetwork.subnet_1.secondary_ip_range[0].ip_cidr_range
  ip_range_services   = google_compute_subnetwork.subnet_1.secondary_ip_range[1].ip_cidr_range
  enable_basic_auth   = false
  enable_legacy_abac  = false
  enable_network_policy = false

  node_pools = {
    default = {
      machine_type = "e2-small"
      min_count    = 1
      max_count    = 2
    }
  }
}