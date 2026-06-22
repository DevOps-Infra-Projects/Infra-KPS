/*
  Blackbox exporter used mainly to monitor external endpoints
*/


data "template_file" "blackbox_values" {
  template = <<EOF

pspEnabled: false
config:
  modules:
    http_2xx:
      prober: http
      timeout: 5s
      http:
        valid_http_versions: ["HTTP/1.1", "HTTP/2.0"]
        follow_redirects: true
        preferred_ip_protocol: "ip4"
    tcp_connect:
      prober: tcp
      timeout: 5s
EOF


}



resource "helm_release" "blackbox" {
  name       = "blackbox"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "prometheus-blackbox-exporter"
  version    = "8.3.0"
  namespace  = kubernetes_namespace.kube-prometheus-stack.metadata[0].name

  # Default values
  # https://github.com/prometheus-community/helm-charts/blob/main/charts/prometheus-blackbox-exporter/values.yaml
  values      = [data.template_file.blackbox_values.rendered]
}
