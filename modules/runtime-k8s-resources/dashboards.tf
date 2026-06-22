resource "kubernetes_config_map" "grafana_dashboard_kubernetes_cluster_prometheus" {
  metadata {
    name = "grafana-dashboard-kubernetes-cluster-prometheus"
    namespace  = kubernetes_namespace.kube-prometheus-stack.metadata[0].name
    labels = { 
      "app.kubernetes.io/managed-by" = "Terraform"
      "grafana_dashboard" = 1
      "based_on" = "grafana.com_6417"
    }
    annotations = {
      "sidecar.grafana.com/dashboard-folder" = "${local.repo}-Misc"
    }
  }

  data = {
    "kubernetes-cluster-prometheus.json" = file("${path.module}/grafana-dashboards/kubernetes-cluster-prometheus.json")
  }
}