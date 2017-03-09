PWD := $(shell pwd)
srcs := vimrc vim vimperator
all: deps

deps: vim/autoload/plug.vim vimperator/plugin/plugin_loader.js
	mkdir -p $(HOME)/.vimtmp
	mkdir -p $(HOME)/.vimback
	mkdir -p $(HOME)/.vimundo

vim/autoload/plug.vim:
	curl -fLo $@ --create-dirs \
	  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

vimperator/vimperator-plugins:
	git clone git@github.com:vimpr/vimperator-plugins.git $(PWD)/$@

vimperator/plugin/plugin_loader.js: vimperator/vimperator-plugins
	mkdir -p vimperator/plugin
	cp vimperator/vimperator-plugins/plugin_loader.js $@

symlink:
	$(foreach src,$(srcs),ln -Fs $(PWD)/$(src) $(HOME)/.$(src);)
