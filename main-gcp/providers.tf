

provider "google" {
  project     = var.gcp_project
  region      = var.gcp_region
}

provider "kubernetes" {
  host  = "https://${data.google_container_cluster.cluster.endpoint}"
  token = data.google_client_config.provider.access_token
  cluster_ca_certificate = base64decode(
    data.google_container_cluster.cluster.master_auth[0].cluster_ca_certificate,
  )
  ignore_annotations = [
    "downscaler\\/exclude-until",
    "downscaler\\/exclude",
    "cloud.google.com\\/neg",
    "downscaler\\/force-uptime"
  ]
}


provider "helm" {
  helm_driver = "configmap"
  debug = false
  
  kubernetes {
    host  = "https://${data.google_container_cluster.cluster.endpoint}"
    token = data.google_client_config.provider.access_token
    cluster_ca_certificate = base64decode(
      data.google_container_cluster.cluster.master_auth[0].cluster_ca_certificate,
    )
  }
  
}


provider "kubectl" {
  load_config_file       = false
  host  = "https://${data.google_container_cluster.cluster.endpoint}"
  token = data.google_client_config.provider.access_token
  cluster_ca_certificate = base64decode(
    data.google_container_cluster.cluster.master_auth[0].cluster_ca_certificate,
  )
}

