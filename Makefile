.ONESHELL:
.PHONEY: help environment init update plan plan-destroy show graph apply output taint-% raw

ifneq ($(origin SECRETS), undefined)
SECRET_VARS = "-var-file=$(SECRETS)"
endif

# KMS keys for the statefile buckets
keys.base       := arn:aws:kms:{{ REGION }}:{{ ACCOUNT_ID }}:key/{{ KEY_ID }}
keys.production := arn:aws:kms:{{ REGION }}:{{ ACCOUNT_ID }}:key/{{ KEY_ID }}
keys.acceptance := arn:aws:kms:{{ REGION }}:{{ ACCOUNT_ID }}:key/{{ KEY_ID }}
keys.management := arn:aws:kms:{{ REGION }}:{{ ACCOUNT_ID }}:key/{{ KEY_ID }}
keys.services   := arn:aws:kms:{{ REGION }}:{{ ACCOUNT_ID }}:key/{{ KEY_ID }}
keys.vpn        := arn:aws:kms:{{ REGION }}:{{ ACCOUNT_ID }}:key/{{ KEY_ID }}

# Identifiers for the AWS accounts
env.base.id       := {{ ACCOUNT_ID }}
env.production.id := {{ ACCOUNT_ID }}
env.acceptance.id := {{ ACCOUNT_ID }}
env.management.id := {{ ACCOUNT_ID }}
env.services.id   := {{ ACCOUNT_ID }}
env.vpn.id        := {{ ACCOUNT_ID }}

# set to include stages that do not need assume
non_assume_goals := help graph environment
role-name := {{ ROLE_NAME }}

ifneq ($(strip $(filter-out $(.DEFAULT_GOAL) $(non_assume_goals),$(MAKECMDGOALS))),)

ifndef ENV
$(error ENV was not set)
endif

$(info assuming account: $(ENV)/$(env.$(ENV).id) role: $(role-name)..)

SESSION := $(shell aws sts assume-role --output json \
 	  --role-arn arn:aws:iam::$(env.$(ENV).id):role/$(role-name) \
 	  --role-session-name $(ENV)_session \
 	  | jq -r '.Credentials | .AccessKeyId + " " + .SecretAccessKey + " " + .SessionToken')

AWS_ACCESS_KEY_ID := $(word 1, $(SESSION))
AWS_SECRET_ACCESS_KEY := $(word 2, $(SESSION))
AWS_SESSION_TOKEN := $(word 3, $(SESSION))

ifndef AWS_SESSION_TOKEN # sanity check
$(error could not assume $(env.$(ENV).id):role/$(role-name)!)
endif

export AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY
export AWS_SESSION_TOKEN

endif

ifeq (raw,$(firstword $(MAKECMDGOALS)))
  # use the rest as arguments for "run"
  RUN_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
  # ...and turn them into do-nothing targets
  $(eval $(RUN_ARGS):;@:)
endif

help:
	@grep -E '^[a-zA-Z_-]+[%]*:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

environment: ## Create new environment. Example: ENV=test make environment
	@if [ -z $(ENV) ]; then\
		echo ENV was not set; exit 1;\
	fi
	@mkdir -p environments/$(ENV)
	@touch environments/$(ENV)/$(notdir $(ENV)).tfvars environments/$(ENV)/$(notdir $(ENV)).tf
	@$(foreach envfile,$(wildcard environments/*.tf),cp $(envfile) environments/$(ENV)/env_$(notdir $(envfile)); )

init: environment
	@rm -rf .terraform/*.tf*
	@terraform remote config \
		-backend=S3 \
		-backend-config="region={{ REGION }}" \
		-backend-config="bucket=terraform-state.$(ENV)" \
		-backend-config="key=$(ENV).tfstate"\
	  	-backend-config="encrypt=1"\
		-backend-config="kms_key_id=$(keys.$(ENV))"
	@terraform remote pull

update: ## Gets a newer version of the state
	@terraform get -update=true environments/$(ENV) 1>/dev/null

plan: init update ## Runs a plan to show proposed changes.
	@terraform plan -input=false -refresh=true -module-depth=-1 $(SECRET_VARS) -var-file=environments/$(ENV)/$(ENV).tfvars -out=terraform_plan environments/$(ENV)

plan-target-%: init update ## Runs a plan to show proposed changes. Example: make plan-target-mymodule.rds.aws_route53_record.rds-master
	@echo "Specifically planning to run $(@:plan-target-%=%)"
	@terraform plan -input=false -refresh=true -module-depth=-1 $(SECRET_VARS) \
		-var-file=environments/$(ENV)/$(ENV).tfvars -out=terraform_plan \
		-target=$(@:plan-target-%=%) environments/$(ENV)

plan-destroy: init update ## Runs a plan to show what will be destroyed
	@terraform plan -input=false -refresh=true -module-depth=-1 -destroy $(SECRET_VARS) -var-file=environments/$(ENV)/$(ENV).tfvars environments/$(ENV)

show: init
	@terraform show -module-depth=-1

graph: ## Creates a graph of the resources that Terraform is aware of
	@rm -f graph.png
	@terraform graph -draw-cycles -module-depth=-1 | dot -Tpng > graph.png
	@open graph.png

apply: init update ## Apply the changes against your environment
	@-terraform apply -input=true -refresh=true terraform_plan && terraform remote push
	@rm -f terraform_plan

output: init update ## Show Terraform output (optionally specify MODULE in the environment)
	@if [ -z $(MODULE) ]; then\
		terraform output;\
	 else\
		terraform output -module=$(MODULE);\
	 fi

taint-%: init update ## Taint resource to force re-creation on next plan/apply. Example: make taint-aws_iam_role_policy_attachment.mypolicy
	@terraform taint $(SECRET_VARS) -var-file=environments/$(ENV)/$(ENV).tfvars \
		-module=$(MODULE) $(@:taint-%=%) &&\
		terraform remote push
	@echo "You will now want to run a plan to see what changes will take place"

destroy: init update ## Destroy a set of resources
	@terraform destroy $(SECRET_VARS) -var-file=environments/$(ENV)/$(ENV).tfvars environments/$(ENV) && terraform remote push

destroy-target-%: init update ## Specifically destroy resource(s). Example: make destroy-target-mymodule.rds.aws_route53_record.rds-master
	@echo "Specifically destroying $(@:destroy-target-%=%)"
	@terraform destroy $(SECRET_VARS) -var-file=environments/$(ENV)/$(ENV).tfvars \
		-target=$(@:destroy-target-%=%) environments/$(ENV) &&\
		terraform remote push

raw: init update ## Initiate raw terraform commands after updating state
	@terraform $(RUN_ARGS)
