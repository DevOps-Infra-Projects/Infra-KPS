
module "runtime-k8s-resources" {
  source                        = "../modules/runtime-k8s-resources"

  platform                      = "gcp"
  region                        = var.gcp_region

  cluster_name                  = var.cluster_name

  cluster_endpoint              = "https://${data.google_container_cluster.cluster.endpoint}"
  cluster_auth_base64           = data.google_container_cluster.cluster.master_auth[0].cluster_ca_certificate


  kps_prom_host                         = var.kps_prom_host
  kps_prom_request_memory               = var.kps_prom_request_memory
  kps_prom_request_cpu                  = var.kps_prom_request_cpu
  kps_prom_limit_memory                 = var.kps_prom_limit_memory
  kps_prom_limit_cpu                    = var.kps_prom_limit_cpu
  kps_prom_retention                    = var.kps_prom_retention
  kps_prom_persistence_size             = var.kps_prom_persistence_size
  kps_prom_scrape_blocket_endpoints     = var.kps_prom_scrape_blocket_endpoints
  kps_prom_scrape_pagespeed             = var.kps_prom_scrape_pagespeed
  kps_prom_scrape_confluent             = var.kps_prom_scrape_confluent
  kps_alert_host                        = var.kps_alert_host
  kps_alert_slack_receivers             = var.kps_alert_slack_receivers
  kps_alert_add_opsgenie                = var.kps_alert_add_opsgenie
  kps_alert_routes                      = var.kps_alert_routes
  kps_alert_add_auth_ingress            = var.kps_alert_add_auth_ingress
  kps_grafana_ingress_enabled           = var.kps_grafana_ingress_enabled
  kps_grafana_oauth_github_client_id    = var.kps_grafana_oauth_github_client_id
  kps_grafana_authelia_oauth_client_id  = var.kps_grafana_authelia_oauth_client_id
  kps_grafana_host                      = var.kps_grafana_host


}