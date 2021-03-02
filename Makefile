default: build
.PHONY: build

get_configs:
	rm -rf env_configs hmpps-engineering-platform-terraform
	git clone git@github.com:ministryofjustice/hmpps-engineering-platform-terraform.git
	mv hmpps-engineering-platform-terraform/env_configs env_configs
	rm -rf hmpps-engineering-platform-terraform

init:
	rm -rf $(COMPONENT)/.terraform/terraform.tfstate

plan: init
	sh run.sh $(ENVIRONMENT_NAME) plan $(COMPONENT) || (exit $$?)

apply:
	sh run.sh $(ENVIRONMENT_NAME) apply $(COMPONENT) || (exit $$?)

terraform: 
	sh run.sh $(ENVIRONMENT_NAME) plan $(component)
	sh run.sh $(ENVIRONMENT_NAME) apply $(component)

ansible:
	sh run.sh $(ENVIRONMENT_NAME) ansible $(component)

lambda_packages:
	rm -rf $(component)
	mkdir $(component)
	aws s3 sync --only-show-errors s3://$(ARTEFACTS_BUCKET)/lambda/eng-lambda-functions-builder/builds/$(LAMBA_BUILD_VERSION)/ $(CODEBUILD_SRC_DIR)/$(component)/

start: restart
	docker-compose exec builder env| sort

stop:
	docker-compose down

cleanup:
	docker-compose down -v --rmi local

restart: stop
	docker-compose up -d

local_plan: restart
	docker-compose exec builder make plan

local_apply: restart
	docker-compose exec builder make apply
