ENVIRONMENT ?= betacloud

VERSION_CEPH ?= pacific
VERSION_MANAGER ?= latest
VERSION_OPENSTACK ?= yoga

TERRAFORM ?= terraform

help:  ## Display this help.
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

clean: ## Destroy infrastructure with Terraform.
	make -C terraform \
	  ENVIRONMENT=$(ENVIRONMENT) \
	  TERRAFORM=$(TERRAFORM) \
	  clean

create: prepare ## Create required infrastructure with Terraform.
	make -C terraform \
	  ENVIRONMENT=$(ENVIRONMENT) \
	  TERRAFORM=$(TERRAFORM) \
	  VERSION_CEPH=$(VERSION_CEPH) \
	  VERSION_MANAGER=$(VERSION_MANAGER) \
	  VERSION_OPENSTACK=$(VERSION_OPENSTACK) \
	  create

login: ## Log in on the manager.
	@make -C terraform \
	  ENVIRONMENT=$(ENVIRONMENT) \
	  login

bootstrap: create ## Bootstrap everything.
	ansible-playbook playbooks/deploy.yml \
	  -i ansible/localhost_inventory.yaml \
	  -e ansible_galaxy=ansible-galaxy \
	  -e ansible_playbook=ansible-playbook \
	  -e basepath="$(PWD)" \
	  -e cloud_env=$(ENVIRONMENT) \
	  -e repo_path="$(PWD)/.src/github.com" \
	  -e manual_create=true \
	  -e manual_deploy=true \
	  -e version_ceph=$(VERSION_CEPH) \
	  -e version_manager=$(VERSION_MANAGER) \
	  -e version_openstack=$(VERSION_OPENSTACK)

manager: bootstrap ## Deploy only the manager service.
	make -C terraform \
	  ENVIRONMENT=$(ENVIRONMENT) \
	  TERRAFORM=$(TERRAFORM) \
	  deploy-manager

identity: manager ## Deploy only identity services.
	make -C terraform \
	  ENVIRONMENT=$(ENVIRONMENT) \
	  TERRAFORM=$(TERRAFORM) \
	  deploy-identity

ceph: manager ## Deploy only ceph services.
	make -C terraform \
	  ENVIRONMENT=$(ENVIRONMENT) \
	  deploy-ceph

deploy: bootstrap ## Deploy everything and then check it.
	make -C terraform \
	  ENVIRONMENT=$(ENVIRONMENT) \
	  TERRAFORM=$(TERRAFORM) \
	  deploy
	make -C terraform \
	  ENVIRONMENT=$(ENVIRONMENT) \
	  TERRAFORM=$(TERRAFORM) \
	  check

prepare: ## Run local preparations.
	ansible-playbook -i localhost, ansible/check-local-versions.yml
	mkdir -p .src/github.com/osism
	if [ ! -e .src/github.com/osism/testbed ]; then git clone https://github.com/osism/testbed .src/github.com/osism/testbed; else git -C .src/github.com/osism/testbed pull; fi
	if [ ! -e .src/github.com/osism/ansible-collection-commons ]; then git clone https://github.com/osism/ansible-collection-commons .src/github.com/osism/ansible-collection-commons; else git -C .src/github.com/osism/ansible-collection-commons pull; fi
	if [ ! -e .src/github.com/osism/ansible-collection-services ]; then git clone https://github.com/osism/ansible-collection-services .src/github.com/osism/ansible-collection-services; else git -C .src/github.com/osism/ansible-collection-services pull; fi

phony: bootstrap clean create deploy identity login manager prepare ceph
