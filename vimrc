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

" autocmdが毎回実行されるのを防ぐ
" cf. http://rbtnn.hateblo.jp/entry/2014/11/30/174749
augroup vimrc
  autocmd!
augroup END

" ==========================
" Import configuration files
" ==========================
source ~/.vim/conf.d/basic.vim
source ~/.vim/conf.d/neobundle.vim
source ~/.vim/conf.d/plugins-nerdtree.vim
source ~/.vim/conf.d/plugins-vim-colors-solarized.vim
source ~/.vim/conf.d/plugins-lightline.vim
" source ~/.vim/conf.d/plugins-***.vim

source ~/.vim/conf.d/color.vim
source ~/.vim/conf.d/key-mapping.vim

source ~/.vim/conf.d/mac.vim

" =================================================
" These settings should be written in end of vimrc
" =================================================
" cf. http://d.hatena.ne.jp/wiredool/20120618/1340019962
filetype on
filetype plugin indent on
