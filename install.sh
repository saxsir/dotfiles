#!/bin/sh

OS="linux"
cd $(dirname $0)

# ==================
# Install submodules
# ==================
git submodule init oh-my-zsh
git submodule init neobundle.vim
if [ $OS = "mac" ]; then
  git submodule init vimperator/vimperator-plugins
fi
git submodule update

if [ -e "$PWD/oh-my-zsh" ]; then
  cd oh-my-zsh
  git checkout master
  cd ..
fi
if [ -e "$PWD/neobundle.vim" ]; then
    cd neobundle.vim
    git checkout master
    cd ..
fi
if [ $OS = "mac" ]; then
  cd vimperator/vimperator-plugins
  git checkout master
  cd ../..
fi

# =====================
# Create symbolic links
# =====================
# git
cp ~/dotfiles/gitconfig.sample ./gitconfig
sed -i -e 's/\<your name\>/saxsir/' ./gitconfig
sed -i -e 's/\<your email\>/saxsir.256+github@gmail.com/' ./gitconfig
ln -Fis "$PWD/gitconfig" ~/.gitconfig
ln -Fis "$PWD/gitignore_global" ~/.gitignore_global

# zsh
ln -Fis "$PWD/zshenv" ~/.zshenv
ln -Fis "$PWD/zshrc" ~/.zshrc
cp -fi  "$PWD/zshrc.mine.sample" ~/.zshrc.mine
ln -Fis "$PWD/oh-my-zsh" ~/.oh-my-zsh

# vim
mkdir -p ~/.vim/bundle
ln -Fis "$PWD/vimrc" ~/.vimrc
ln -Fis "$PWD/neobundle.vim" ~/.vim/bundle/neobundle.vim
ln -Fis "$PWD/vim/editorconfig" ~/.vim/.editorconfig

# gem
ln -Fis "$PWD/gemrc" ~/.gemrc

# ==========================
# Vimperator(Macintosh only)
# ==========================
if [ $OS = "mac" ]; then
  ln -Fis "$PWD/vimperatorrc" ~/.vimperatorrc
  if [ ! -e ~/.vimperator ]; then
    mkdir ~/.vimperator
  fi
  if [ ! -e ~/.vimperator/plugin ]; then
    mkdir ~/.vimperator/plugin
  fi
  ln -Fis "$PWD/vimperator/colors" ~/.vimperator/
  ln -Fis "$PWD/vimperator/vimperator-plugins" ~/.vimperator/
  ln -Fis "$PWD/vimperator/vimperator-plugins/plugin_loader.js" ~/.vimperator/plugin/
fi
