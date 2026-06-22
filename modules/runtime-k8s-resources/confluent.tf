resource "kubectl_manifest" "confluent_scrape_pre" {
  count = var.kps_prom_scrape_confluent ? 1 : 0
  yaml_body = <<YAML
apiVersion: monitoring.coreos.com/v1alpha1
kind: ScrapeConfig
metadata:
  name: confluent-pre
  namespace: confluent
  labels:
    release: kps
    repo: infrastructure-mrissa-kps
spec:
  scrapeInterval: 1m
  scrapeTimeout: 1m
  honorTimestamps: true
  staticConfigs:
    - targets: ['api.telemetry.confluent.cloud']
      labels:
        env: pre
  scheme: HTTPS
  metricsPath: /v2/metrics/cloud/export
  params:
    "resource.kafka.id":
      - lkc-512ooq
  basicAuth:
    username:
      name: confluent-prometheus-pro
      key: username
    password:
      name: confluent-prometheus-pro
      key: password
YAML

}


resource "kubectl_manifest" "confluent_scrape_pro" {
  count = var.kps_prom_scrape_confluent ? 1 : 0
  yaml_body = <<YAML
apiVersion: monitoring.coreos.com/v1alpha1
kind: ScrapeConfig
metadata:
  name: confluent-pro
  namespace: confluent
  labels:
    release: kps
    repo: infrastructure-mrissa-kps
spec:
  scrapeInterval: 1m
  scrapeTimeout: 1m
  honorTimestamps: true
  staticConfigs:
    - targets: ['api.telemetry.confluent.cloud']
      labels:
        env: pro
  scheme: HTTPS
  metricsPath: /v2/metrics/cloud/export
  params:
    "resource.kafka.id":
      - lkc-zvk97
  basicAuth:
    username:
      name: confluent-prometheus-pro
      key: username
    password:
      name: confluent-prometheus-pro
      key: password
YAML

}
