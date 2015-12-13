" Skip initialization for vim-tiny or vim-small.
if !1 | finish | endif

filetype off                " required!
filetype plugin indent off

if has('vim_starting')
  if &compatible
    set nocompatible      " Be iMproved
  endif
  set runtimepath+=~/.vim/bundle/neobundle.vim/    " required!
endif

" プラグインに依存していない設定の読み込み
runtime! vimrc.d/*.vim

" プラグインの読み込み
call neobundle#begin(expand('~/.vim/bundle/'))    " required!
NeoBundleFetch 'Shougo/neobundle.vim'    " required!
runtime! vimrc.d/plugins/*.vim
call neobundle#end()    " required!

syntax on
filetype plugin indent on    " required!
NeoBundleCheck
