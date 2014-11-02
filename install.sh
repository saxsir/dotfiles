#!/bin/sh

cd $(dirname $0)

# install neobundle.git
if [ ! -e ~/.vim/bundle/neobundle.vim'' ]; then
  echo "Installing neobundle.vim..."
  mkdir -p ~/.vim/bundle
  git clone https://github.com/Shougo/neobundle.vim ~/.vim/bundle/neobundle.vim
fi

# update submodule
echo "Updating submodules(oh-my-zsh, vimperator-plugins)..."
git submodule init
git submodule update
if [ -e "$PWD/oh-my-zsh" ]; then
  cd oh-my-zsh
  git checkout master
  cd ..
fi
if [ -e "$PWD/vimperator/vimperator-plugins" ]; then
  cd vimperator/vimperator-plugins
  git checkout master
  cd ../..
fi

# create symbolic link
echo "Creating symbolic links..."
ln -Fis "$PWD/zshenv" ~/.zshenv
ln -Fis "$PWD/zshrc" ~/.zshrc
cp -fi  "$PWD/zshrc.mine.sample" ~/.zshrc.mine
ln -Fis "$PWD/oh-my-zsh" ~/.oh-my-zsh
ln -Fis "$PWD/gitignore_global" ~/.gitignore_global
ln -Fis "$PWD/gitconfig" ~/.gitconfig
ln -Fis "$PWD/vimrc" ~/.vimrc
ln -Fis "$PWD/gemrc" ~/.gemrc
ln -Fis "$PWD/vimperatorrc" ~/.vimperatorrc
if [ ! -e ~/.vimperator ]; then
  mkdir -p ~/.vimperator
fi
if [ ! -e ~/.vimperator/plugin ]; then
  mkdir -p ~/.vimperator/plugin
fi
ln -Fis "$PWD/vimperator/colors" ~/.vimperator/
ln -Fis "$PWD/vimperator/vimperator-plugins" ~/.vimperator/
ln -Fis "$PWD/vimperator/vimperator-plugins/plugin_loader.js" ~/.vimperator/plugin/
if [ ! -e ~/.vim ]; then
  mkdir -p ~/.vim
fi
ln -Fis "$PWD/vim/dict" ~/.vim/

