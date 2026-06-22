terraform {
  required_version = "~> 1.2"

  required_providers {
    google    = {
      source  = "hashicorp/google"
      version = "4.68.0"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.21.1"
    }
    helm = {
      source = "hashicorp/helm"
      version = "2.10.1"
    }
    kubectl = {
      source = "gavinbunney/kubectl"
      version = "1.14"
    }
    template = {
      source = "hashicorp/template"
    }
  }
  backend "gcs" {
  }
}

