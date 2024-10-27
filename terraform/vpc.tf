resource "google_compute_network" "gke-vpc-1" {
  name                    = "gke-vpc-1"
  routing_mode            = "REGIONAL"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "primary-subnet-1" {
  name                     = "primary-subnet-1"
  ip_cidr_range            = "10.0.0.0/16"
  network                  = google_compute_network.gke_vpc_1.self_link
  private_ip_google_access = true
  region                   = "us-central1"

  secondary_ip_range {
    range_name    = "services-ip-range"
    ip_cidr_range = "10.1.0.0/16"
  }

  secondary_ip_range {
    range_name    = "pods-ip-range"
    ip_cidr_range = "10.2.0.0/16"
  }
}

