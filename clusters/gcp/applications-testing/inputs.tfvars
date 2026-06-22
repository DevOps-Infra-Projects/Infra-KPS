gcp_region       = "europe-west1"
gcp_location     = "europe-west1-b"
gcp_project      = "galaxy-platform-pre"


kps_prom_host                         = "prometheus-pre.myorg"
kps_prom_request_memory               = "4Gi"
kps_prom_limit_memory                 = "4Gi"
kps_prom_request_cpu                  = "500m"
kps_prom_limit_cpu                    = "2"
kps_prom_retention                    = "3d"
kps_prom_persistence_size             = "25"
kps_prom_scrape_pagespeed             = false
kps_prom_scrape_blocket_endpoints     = false
kps_grafana_ingress_enabled           = true
kps_grafana_oauth_github_client_id    = ""
kps_grafana_authelia_oauth_client_id  = "grafana-pre"
kps_grafana_host                      = "grafana-pre.myorg"
kps_alert_host                        = "alertmanager-pre.myorg"
kps_alert_add_auth_ingress            = false
kps_alert_add_opsgenie                = false
