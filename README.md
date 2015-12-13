dotfiles
========

設定ファイルとかとか

## Requirement
```
$ ansible-playbook --version
ansible-playbook 1.9.4
```

## Install
```
$ make install
```

The ansible recipes are creating symbolic links to dotfiles, and installing some useful bundles(oh-myzsh, zsh-completions, and so on).


Details => see `localhost.yml`.

## Important
If you want to use my dotfiles, you MUST change username and email in gitconfig.

```
[user]
    name = your username on GitHub
    email = your email on GitHub
```

