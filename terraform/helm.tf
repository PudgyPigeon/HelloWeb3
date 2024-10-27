provider "helm" {
  kubernetes {
    host                   = "https://${module.gke.endpoint}"
    token                  = data.google_client_config.default.access_token
  }
}

# resource "helm_release" "example" {
#   name  = "my-local-chart"
#   chart = "./helm"

#   depends_on = [
#     module.gke.cluster
#   ]
# }