DOCKER:=$(shell which docker)

.PHONY: deploy-gitlab
deploy-gitlab:
	@$(DOCKER) run --detach \
  		--hostname git.local \
  		--publish 443:443 --publish 80:80 --publish 22:22 \
  		--name gitlab \
  		--restart always \
  		--shm-size 256m \
		gitlab/gitlab-ce:latest

.PHONY: start-gitlab
start-gitlab:
	$(DOCKER) start gitlab 

.PHONY: stop-gitlab
stop-gitlab:
	$(DOCKER) stop gitlab 

.PHONY: destroy-gitlab
destroy-gitlab:
	$(DOCKER) rm gitlab 

.PHONY: get-root-password
get-root-password:
	$(DOCKER) exec -it gitlab cat /etc/gitlab/initial_root_password
