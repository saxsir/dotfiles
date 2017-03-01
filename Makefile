PWD := $(shell pwd)
srcs := vimrc vim

all: deps

deps: vim/autoload/plug.vim
	mkdir -p $(HOME)/.vimtmp
	mkdir -p $(HOME)/.vimback
	mkdir -p $(HOME)/.vimundo

vim/autoload/plug.vim:
	curl -fLo $@ --create-dirs \
	  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

symlink:
	$(foreach src,$(srcs),ln -Fs $(PWD)/$(src) $(HOME)/.$(src);)
