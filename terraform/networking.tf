resource "kubernetes_namespace" "nginx" {
  depends_on = [module.gke]
  metadata {
    name = "nginx"
  }
}

resource "kubernetes_namespace" "cert-manager" {
  depends_on = [module.gke]
  metadata {
    name = "cert-manager"
  }
}

module "nginx-controller" {
  source  = "terraform-iaac/nginx-controller/helm"

  namespace = kubernetes_namespace.nginx.metadata[0].name

}

module "cert_manager" {
  source        = "terraform-iaac/cert-manager/kubernetes"
  create_namespace = false
  namespace_name = kubernetes_namespace.cert-manager.metadata[0].name

  cluster_issuer_email                   = var.cluster_issuer_email
  cluster_issuer_name                    = var.cluster_issuer_name
  cluster_issuer_private_key_secret_name = var.cluster_issuer_private_key_secret_name


  solvers = [
    {
      http01 = {
        ingress = {
          class = "nginx"
        }
      }
    }
  ]
}