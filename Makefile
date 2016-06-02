all: install vimperator/vimperator-plugins update-vimperator-plugins

ANSIBLE_PLAYBOOK := $(shell which ansible-playbook)

install:
	$(ANSIBLE_PLAYBOOK) -i hosts -vv localhost.yml

vimperator/vimperator-plugins:
	git clone https://github.com/vimpr/vimperator-plugins.git $@
	ln -s $@/plugin_loader.js vimperator/plugin/

update-vimperator-plugins:
	cd ./vimperator/vimperator-plugins && git pull origin master

srcs:=vimrc vim vimperator vimperatorrc gitconfig zshrc tmux.conf
link:
	$(foreach src,$(srcs),ln -Fs $(PWD)/$(src) $(HOME)/.$(src);)
