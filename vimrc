" Skip initialization for vim-tiny or vim-small.
if !1 | finish | endif

if &compatible
  set nocompatible
endif
set runtimepath+=~/src/github.com/Shougo/dein.vim

" プラグインに依存していない設定の読み込み
runtime! vimrc.d/*.vim

call dein#begin(expand('~/.cache/dein'))
call dein#add('Shougo/dein.vim')

" Add or remove your plugins here:
call dein#add('Shougo/vimshell')

runtime! vimrc.d/plugins/*.vim

call dein#end()

syntax on
filetype plugin indent on

" If you want to install not installed plugins on startup.
if dein#check_install()
 call dein#install()
endif
