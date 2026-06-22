variable "platform" { 
  type = string
  validation {
    condition     = length(regexall("^(aws|gcp)$", var.platform)) > 0
    error_message = "ERROR: Valid types are \"aws\" and \"gcp\"!"
  }
}


variable "cluster_name" {
  description = "EKS or GKE cluster name"
}

variable "region" {
  description = "AWS or GCP region"
}

variable "cluster_endpoint" {
  description = ""
}
variable "cluster_auth_base64" {
  description = ""
}


variable "prefix_hosts" {
  type = string
  default = ""
  description = "temporary variable to prefix gke cluster urls to not conflict with EKS, will remove once migration is done"
}




############# Kube-prometheus-stack variables ################
variable "kps_prom_host" {
  type = string
}
variable "kps_prom_request_memory" {
  type = string
}
variable "kps_prom_request_cpu" {
  type = string
}
variable "kps_prom_limit_memory" {
  type = string
}
variable "kps_prom_limit_cpu" {
  type = string
}

variable "kps_prom_retention" {
  type = string
  description = "Prometheus retention"
}

variable "kps_prom_persistence_size" {
  type = string
  description = "EBS size in Gi"
}

variable "kps_prom_scrape_blocket_endpoints" {
  type = bool
}

variable "kps_prom_scrape_pagespeed" {
  type = bool
}
variable "kps_prom_scrape_confluent" {
  type = bool
}
variable "kps_alert_host" {
  type = string
}
variable "kps_alert_add_opsgenie" {
  type = bool
  description = "Should add opsgenie receiver"
}

variable "kps_alert_add_auth_ingress" {
  type = bool
  description = "Add an other ingress for basic auth"
}

variable "kps_alert_routes" {
  type = string
  description = "alertmanager routes"
}

variable "kps_alert_slack_receivers" {
  type = string
}

variable "kps_grafana_host" {
  type = string
}

variable "kps_grafana_ingress_enabled" {
  type = string
}

variable "kps_grafana_oauth_github_client_id" {
  type = string
}

variable "kps_grafana_authelia_oauth_client_id" {
  type = string
}


