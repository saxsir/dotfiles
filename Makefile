PWD := $(shell pwd)
srcs := \
  gitconfig gitignore_global gitmessage.txt \
  vimrc tmux.conf \
  zshrc zshrc.darwin zshrc.linux ideavimrc mackup.cfg

all: deps symlink

deps:
	mkdir -p $(HOME)/.vimtmp
	mkdir -p $(HOME)/.vimback
	mkdir -p $(HOME)/.vimundo
	mkdir -p $(HOME)/.config
	@if command -v brew >/dev/null 2>&1; then \
		brew install --cask font-plemol-jp-nf 2>/dev/null || true; \
	fi

symlink: $(HOME)/.vim $(HOME)/.zshrc.local $(HOME)/.config/nvim $(HOME)/.config/ghostty $(HOME)/.config/starship.toml $(HOME)/.claude/commands $(HOME)/.claude/agents $(HOME)/.claude/rules $(HOME)/.claude/skills $(HOME)/.claude/settings.json $(HOME)/.claude/statusline.sh $(HOME)/.claude/hooks $(HOME)/.claude/CLAUDE.md
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

$(HOME)/.config/ghostty:
	mkdir -p $(HOME)/.config
	ln -Fs $(PWD)/ghostty/ $@

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

$(HOME)/.claude/statusline.sh:
	ln -fs $(PWD)/claude/statusline.sh $@

$(HOME)/.claude/hooks:
	ln -Fs $(PWD)/claude/hooks/ $@

$(HOME)/.claude/CLAUDE.md:
	ln -fs $(PWD)/claude/CLAUDE.md $@
