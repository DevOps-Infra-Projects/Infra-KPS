locals {

}


resource "kubernetes_namespace" "kube-prometheus-stack" {
  metadata {
    name   = "kube-prometheus-stack"
    labels = { 
      "app.kubernetes.io/name" = "kube-prometheus-stack" 
    }
    annotations = {
      "downscaler/exclude"      = "true"
    }
  }
}