locals {

  repo = "infrastructure-mrissa-kps"

  shared_k8s_labels = {
    "managed-by"          = "terraform"
    "myorg/repo"  = local.repo
  }


}


