PULUMI:=$(shell which pulumi)
DOCKER:=$(shell which docker)
PULUMI_STATE?=--local
PULUMI_CONFIG_PASSPHRASE?=dev
PULUMI_STACK?=dev

export PULUMI_CONFIG_PASSPHRASE

.PHONY: config
config: ## Login
	$(PULUMI) config

.PHONY: login
login: ## Login
	$(PULUMI) login ${PULUMI_STATE}

.PHONY: logout
logout: ## Logout
	$(PULUMI) logout

.PHONY: preview
preview: ## Preview Changes
	$(PULUMI) preview

.PHONY: select
select: ## Apply changes
	$(PULUMI) stack select ${PULUMI_STACK}

.PHONY: up
up: ## Apply changes
	$(PULUMI) up -y

.PHONY: start-gitlab
start-gitlab:
	@$(DOCKER) run --detach \
  		--hostname git.local \
  		--publish 443:443 --publish 80:80 --publish 22:22 \
  		--name gitlab \
  		--restart always \
  		--shm-size 256m \
		gitlab/gitlab-ce:latest

.PHONY: stop-gitlab
stop-gitlab:
	$(DOCKER) stop gitlab 

.PHONY: destroy-gitlab
destroy-gitlab:
	$(DOCKER) rm gitlab 

.PHONY: get-root-password
get-root-password:
	$(DOCKER) exec -it gitlab cat /etc/gitlab/initial_root_password
