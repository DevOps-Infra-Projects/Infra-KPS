terraform {
  required_providers {
    kubectl = {
      #this resolve an ambiquity, terraform will look for hashicorp/kubectl module if not set
      source = "gavinbunney/kubectl" 
    }
  }
}