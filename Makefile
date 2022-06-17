PWD := $(shell pwd)
srcs := \
  gitconfig gitignore_global gitmessage.txt \
  vimrc tmux.conf \
  zshrc zshrc.darwin zshrc.linux ideavimrc mackup.cfg

all: deps symlink

deps: vim/autoload/plug.vim oh-my-zsh/custom/plugins/zsh-completions oh-my-zsh/custom/plugins/zsh-autosuggestions
	mkdir -p $(HOME)/.vimtmp
	mkdir -p $(HOME)/.vimback
	mkdir -p $(HOME)/.vimundo

vim/autoload/plug.vim:
	curl -fLo $@ --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

oh-my-zsh/custom/plugins/zsh-completions: oh-my-zsh
	git clone git@github.com:zsh-users/zsh-completions.git $@

oh-my-zsh/custom/plugins/zsh-autosuggestions: oh-my-zsh
	git clone git@github.com:zsh-users/zsh-autosuggestions $@

oh-my-zsh:
	git clone git@github.com:ohmyzsh/ohmyzsh.git $(PWD)/$@

symlink: $(HOME)/.vim $(HOME)/.oh-my-zsh $(HOME)/.zshrc.local
	$(foreach src, $(srcs), \
	  ln -fs $(PWD)/$(src) $(HOME)/.$(src); \
	  )

$(HOME)/.vim:
	ln -Fs $(PWD)/vim/ $@

$(HOME)/.oh-my-zsh:
	ln -Fs $(PWD)/oh-my-zsh/ $@

$(HOME)/.zshrc.local:
	cp zshrc.local.sample $@
