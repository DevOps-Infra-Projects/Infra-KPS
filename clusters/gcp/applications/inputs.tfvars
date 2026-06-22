gcp_region       = "europe-west1"
gcp_location     = "europe-west1"
gcp_project      = "galaxy-platform"



kps_prom_host                         = "prometheus.myorg"
kps_prom_request_memory               = "8Gi"
kps_prom_request_cpu                  = "2000m"
kps_prom_limit_memory                 = "8Gi"
kps_prom_limit_cpu                    = "2000m"
kps_prom_retention                    = "5d"
kps_prom_persistence_size             = "50"
kps_prom_scrape_pagespeed             = false
kps_prom_scrape_confluent             = true
kps_grafana_ingress_enabled           = true
kps_grafana_oauth_github_client_id    = ""
kps_grafana_authelia_oauth_client_id  = "grafana"
kps_grafana_host                      = "grafana.myorg"
kps_alert_host                        = "alertmanager.myorg"
kps_alert_add_auth_ingress            = false
kps_alert_add_opsgenie                = false

