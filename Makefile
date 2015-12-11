GIT := $(shell which git)

submodule-update:
	$(GIT) submodule foreach git pull origin master
