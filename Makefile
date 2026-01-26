PWD := $(shell pwd)
srcs := \
  gitconfig gitignore_global gitmessage.txt \
  vimrc tmux.conf \
  zshrc zshrc.darwin zshrc.linux ideavimrc mackup.cfg

all: deps symlink

deps: vim/autoload/plug.vim
	mkdir -p $(HOME)/.vimtmp
	mkdir -p $(HOME)/.vimback
	mkdir -p $(HOME)/.vimundo
	mkdir -p $(HOME)/.config

vim/autoload/plug.vim:
	curl -fLo $@ --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

symlink: $(HOME)/.vim $(HOME)/.zshrc.local $(HOME)/.config/nvim $(HOME)/.config/starship.toml $(HOME)/.claude/commands $(HOME)/.claude/agents $(HOME)/.claude/rules $(HOME)/.claude/skills $(HOME)/.claude/settings.json
	$(foreach src, $(srcs), \
	  ln -fs $(PWD)/$(src) $(HOME)/.$(src); \
	  )

$(HOME)/.vim:
	ln -Fs $(PWD)/vim/ $@

$(HOME)/.zshrc.local:
	cp zshrc.local.sample $@

$(HOME)/.config/nvim:
	mkdir -p $(HOME)/.config
	ln -Fs $(PWD)/nvim/ $@

$(HOME)/.config/starship.toml:
	mkdir -p $(HOME)/.config
	ln -fs $(PWD)/starship.toml $@

$(HOME)/.claude/commands:
	ln -Fs $(PWD)/claude/commands/ $@

$(HOME)/.claude/agents:
	ln -Fs $(PWD)/claude/agents/ $@

$(HOME)/.claude/rules:
	ln -Fs $(PWD)/claude/rules/ $@

$(HOME)/.claude/skills:
	ln -Fs $(PWD)/claude/skills/ $@

$(HOME)/.claude/settings.json:
	ln -fs $(PWD)/claude/settings.json $@
