variable "gcp_region" {
  description = "GCP Region"
}
variable "gcp_location" {
  description = "GCP Region or zone"
}
variable "gcp_project" {
  description = "GCP Project"
}

variable "cluster_name" {
  description = "GKE cluster name"
}

############# Kube-prometheus-stack variables ################
variable "kps_prom_host" {
  type = string
}
variable "kps_prom_request_memory" {
  type = string
  default = "1Gi"
}
variable "kps_prom_request_cpu" {
  type = string
  default = "200m"
}
variable "kps_prom_limit_memory" {
  type = string
  default = "1Gi"
}
variable "kps_prom_limit_cpu" {
  type = string
  default = "200m"
}

variable "kps_prom_retention" {
  type = string
  default = "30d"
}

variable "kps_prom_persistence_size" {
  type = string
  default = "5"
}

variable "kps_prom_scrape_blocket_endpoints" {
  type = bool
  default = false
}

variable "kps_prom_scrape_pagespeed" {
  type = bool
  default = false
}
variable "kps_prom_scrape_confluent" {
  type = bool
  default = false
}
variable "kps_alert_host" {
  type = string
}
variable "kps_alert_add_opsgenie" {
  type = bool
  default = false
}

variable "kps_alert_routes" {
  type = string
}
variable "kps_alert_slack_receivers" {
  type = string
}

variable "kps_alert_add_auth_ingress" {
  type = bool
  description = "Add an other ingress for basic auth"
  default = false
}


variable "kps_grafana_ingress_enabled" {
  type = bool
  default = false
}

variable "kps_grafana_oauth_github_client_id" {
  type = string
}

variable "kps_grafana_authelia_oauth_client_id" {
  type = string
}

variable "kps_grafana_host" {
  type = string
}




