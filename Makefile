ANSIBLE_PLAYBOOK := $(shell which ansible-playbook)

install:
	$(ANSIBLE_PLAYBOOK) -i hosts -vv localhost.yml
