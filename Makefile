PWD := $(shell pwd)
srcs := \
  gitconfig gitignore_global gitmessage.txt \
  vimrc vimperatorrc tmux.conf \
  zshenv zshrc zshrc.darwin zshrc.linux


all: deps symlink

deps: vim/autoload/plug.vim vimperator/plugin/plugin_loader.js oh-my-zsh/custom/plugins/zsh-completions $(HOME)/.vim $(HOME)/.oh-my-zsh
	mkdir -p $(HOME)/.vimtmp
	mkdir -p $(HOME)/.vimback
	mkdir -p $(HOME)/.vimundo

vim/autoload/plug.vim:
	curl -fLo $@ --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

vimperator/plugin/plugin_loader.js: vimperator/vimperator-plugins
	mkdir -p vimperator/plugin
	cp vimperator/vimperator-plugins/plugin_loader.js $@

vimperator/vimperator-plugins:
	git clone git@github.com:vimpr/vimperator-plugins.git $(PWD)/$@

oh-my-zsh/custom/plugins/zsh-completions: oh-my-zsh
	git clone git://github.com/zsh-users/zsh-completions.git $@

oh-my-zsh:
	git clone git://github.com/robbyrussell/oh-my-zsh.git $(PWD)/$@

#
# File symlinks
#
symlink: $(HOME)/.vim $(HOME)/.oh-my-zsh
	$(foreach src, $(srcs), \
	  ln -fs $(PWD)/$(src) $(HOME)/.$(src); \
	  )

$(HOME)/.zshrc.local:
	cp zshrc.local.sample $@

#
# Directory symlinks
#
$(HOME)/.vim:
	ln -Fs $(PWD)/vim/ $@

$(HOME)/.oh-my-zsh:
	ln -Fs $(PWD)/oh-my-zsh/ $@
