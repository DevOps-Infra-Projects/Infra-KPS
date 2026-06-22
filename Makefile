.PHONY: init
init: check-platform
	terraform -chdir=main-$(platform) \
	init -reconfigure \
	-backend-config=../clusters/$(platform)/$(cluster)/backend.hcl


.PHONY: plan
plan: check-platform check-cluster init
	terraform -chdir=main-$(platform) \
	plan \
	-var-file=../clusters/$(platform)/$(cluster)/inputs.tfvars \
	-var 'cluster_name=$(cluster)'


.PHONY: apply
apply: check-platform check-cluster init
	terraform -chdir=main-$(platform) \
	apply \
	-var-file=../clusters/$(platform)/$(cluster)/inputs.tfvars \
	-var 'cluster_name=$(cluster)'




.PHONY: check-cluster
check-cluster:
ifndef cluster
	$(error "cluster" is undefined, Please set "cluster")
endif
	@ls clusters/$(platform) | sort | grep -q "^$(cluster)$$" || (echo "\"$(cluster)\" not found in clusters folder"; exit 1)

.PHONY: check-platform
check-platform:
ifndef platform
	$(error "platform" is undefined, Please set "platform", valid values are: aws, gcp)
endif
	@echo "aws gcp" | grep -w -q "$(platform)" || (echo "\"platform\" invalid, valid values are: aws, gcp"; exit 1)


.PHONY: help
help:
	@echo "This Makefile is thin wrapper for Terraform to easily provision and manage multiple Mrissa clusters"
	@echo
	@echo "Syntax: make action param1=value1 param2=value2, ..."
	@echo
	@echo "params:"
	@echo "cluster     Mrissa cluster"
	@echo "platform    aws|gcp"
	@echo
	@echo "actions:"
	@echo "plan         params: cluster,module    help: terraform plan wrapper"
	@echo "apply        params: cluster,module    help: terraform apply wrapper"
