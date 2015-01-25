" ===================
" Required configuration
" ===================

" Note the order of 'set encoding' and 'scriptencoding'
" cf. http://rbtnn.hateblo.jp/entry/2014/11/30/174749
set encoding=utf-8
scriptencoding utf-8

" Not required, this option also change other options.
" cf. https://github.com/vim-jp/vimdoc-ja/blob/master/doc/options.jax Line.1720
" set nocompatible

" 一旦ファイルタイプ関連を無効化する
filetype off
filetype plugin indent off

" ==========================
" Import configuration files
" ==========================
source ~/.vim/conf.d/basic.vimrc
source ~/.vim/conf.d/neobundle.vimrc
source ~/.vim/conf.d/plugins-nerdtree.vimrc
source ~/.vim/conf.d/plugins-vim-colors-solarized.vimrc
" source ~/.vim/conf.d/plugins-***.vimrc
source ~/.vim/conf.d/color.vimrc
source ~/.vim/conf.d/key-mapping.vimrc

" 最後に書く
" cf. http://d.hatena.ne.jp/wiredool/20120618/1340019962
filetype on
filetype plugin indent on
