provider "helm" {
  kubernetes {
    host                   = module.gke.endpoint
    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(module.gke.ca_certificate)
  }
}

resource "kubernetes_namespace" "helloweb3" {
  metadata {
    name = "helloweb3"
  }
}

resource "kubernetes_secret" "polygon_api_key" {
  metadata {
    name      = "polygon-api-key"
    namespace = kubernetes_namespace.helloweb3.metadata[0].name
  }

  data = {
    POLYGON_API_KEY     = var.polygon_api_key
  }

  type = "Opaque"
}

# resource "helm_release" "polygon" {
#   name  = "polygon"
#   chart = "../helm/helloWeb3"
#   namespace  = kubernetes_namespace.polygon.metadata[0].name

#   depends_on = [
#     module.gke.cluster
#   ]

#   set {
#     name  = "service.type"
#     value = "LoadBalancer"
#   }

#   set {
#     name  = "service.port"
#     value = "3000"
#   }

#   set {
#     name  = "service.targetPort"
#     value = "3000"
#   }

#   set {
#     name  = "image.repository"
#     value = "us-docker.pkg.dev/helloweb3-439906/helloweb3-docker-repository/polygon"
#   }

#   set {
#     name  = "image.pullPolicy"
#     value = "IfNotPresent"
#   }

#   set {
#     name  = "image.tag"
#     value = "v0.0.1g"
#   }

#   set {
#     name  = "metrics.enabled"
#     value = "true"
#   }

#   set {
#     name  = "metrics.service.annotations.prometheus.io/scrape"
#     value = "true"
#   }

#   set {
#     name  = "metrics.service.annotations.prometheus.io/port"
#     value = "3000"
#   }
# }