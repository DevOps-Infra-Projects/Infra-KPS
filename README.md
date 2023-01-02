# How To manage the k8s resource?

## Create/Update with Terraform

Update can be made using the makefile targets wrapper

* Plan testing cluster `make platform=aws cluster=applications-testing plan`
* Apply Testing cluster `make platform=aws cluster=applications-testing apply`
* Plan prod cluster `make platform=aws cluster=applications plan`
* Apply prod cluster `make platform=aws cluster=applications apply`