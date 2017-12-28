PWD := $(shell pwd)
srcs := \
  gitconfig gitignore_global gitmessage.txt \
  vimrc tmux.conf \
  zshenv zshrc zshrc.darwin zshrc.linux \
  misc/bin/git-blame-pr.pl \
  misc/com.googlecode.iterm2.plist

all: deps symlink

deps: vim/autoload/plug.vim oh-my-zsh/custom/plugins/zsh-completions $(HOME)/.vim $(HOME)/.oh-my-zsh
	mkdir -p $(HOME)/.vimtmp
	mkdir -p $(HOME)/.vimback
	mkdir -p $(HOME)/.vimundo
	mkdir -p $(HOME)/.misc/bin

vim/autoload/plug.vim:
	curl -fLo $@ --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

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
