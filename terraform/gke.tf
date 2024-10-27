data "google_client_config" "default" {}

provider "kubernetes" {
  host                   = "https://${module.gke.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke.ca_certificate)
}

# Create a GKE cluster
module "gke" {
  source                     = "terraform-google-modules/kubernetes-engine/google"
  name                       = var.gke_cluster_name
  project_id                 = var.project_id
  region                     = var.region
  zones                      = var.gke_cluster_zones 
  network                    = google_compute_network.gke-vpc-1.name
  subnetwork                 = google_compute_subnetwork.primary-subnet-1.name
  ip_range_pods              = google_compute_subnetwork.primary-subnet-1.secondary_ip_range[1].range_name
  ip_range_services          = google_compute_subnetwork.primary-subnet-1.secondary_ip_range[0].range_name
  http_load_balancing        = false
  network_policy             = false
  horizontal_pod_autoscaling = true
  filestore_csi_driver       = false
  dns_cache                  = false

  node_pools = [
    {
        name = "default-node-pool",
        machine_type = "e2-small",
        min_count    = 1,
        max_count    = 2,
        spot         = true,

    },
  ]
}