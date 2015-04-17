" ======================
" Vim configuration file
" @author saxsir (https://github.com/saxsir)
" ======================
filetype off                " required!
filetype plugin indent off

" ================================
" Plugins installation (NeoBundle)
" ================================
" Skip initialization for vim-tiny or vim-small.
if !1 | finish | endif

if has('vim_starting')
  if &compatible
    set nocompatible      " Be iMproved
  endif

  " Required:
  set runtimepath+=~/.vim/bundle/neobundle.vim/
endif

" Required:
call neobundle#begin(expand('~/.vim/bundle/'))

" Let NeoBundle manage NeoBundle
" Required:
NeoBundleFetch 'Shougo/neobundle.vim'

" My Bundles here:
" Refer to |:NeoBundle-examples|.
" Note: You don't set neobundle setting in .gvimrc!
NeoBundle 'itchyny/lightline.vim'
NeoBundle 'bronson/vim-trailing-whitespace'
NeoBundle 'scrooloose/nerdtree'
NeoBundle 'tyru/caw.vim.git'
NeoBundle 'evidens/vim-twig'
NeoBundle 'ConradIrwin/vim-bracketed-paste'

call neobundle#end()

" Required:
filetype plugin indent on

" If there are uninstalled bundles found on startup,
" this will conveniently prompt you to install them.
NeoBundleCheck

" ==============================
" lightline plugin configuration
" ==============================
let g:lightline = {
      \ 'colorscheme': 'solarized_dark',
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ],
      \             [ 'readonly', 'absolutepath', 'modified' ] ]
      \ },
      \ 'component': {
      \   'readonly': '%{&readonly?"[read only]":""}',
      \ },
      \ 'separator': { 'left': '', 'right': '' },
      \ 'subseparator': { 'left': '', 'right': '' }
      \ }

" ==============================
" NERD Tree plugin configuration
" ==============================
" 隠しファイルを表示
let g:NERDTreeShowHidden = 1

" ===========
" Key mapping
" ===========
" leader is ,
let mapleader = ","

" reload vimrc
noremap <C-c><C-e>e :edit $HOME/.vimrc<CR>
noremap <C-c><C-e>s :source $HOME/.vimrc<CR>

" jjでエスケープ
inoremap jj <ESC>

" ノーマルモード時だけ ; と : を入れ替える（USキーボード仕様）
nnoremap ; :
nnoremap : ;

" ctrl+eでNERDTreeを開く
nnoremap <silent><C-e> :NERDTreeToggle<CR>

" , cでコメントアウト(複数行可)
nmap <Leader>c <Plug>(caw:i:toggle)
vmap <Leader>c <Plug>(caw:i:toggle)
" , aで行末にコメント追加
nmap <Leader>a <Plug>(caw:a:toggle)

" Tab操作を簡単に。
nnoremap <C-t>  <Nop>
nnoremap <C-t>n  :<C-u>tabnew<CR>
nnoremap <C-t>c  :<C-u>tabclose<CR>
nnoremap <C-t>l :<C-u>execute 'tabnext' 1 + (tabpagenr() + v:count1 - 1) % tabpagenr('$')<CR>
nnoremap <C-t>h  gT

" splitの移動を簡単に。ctrl押しながらhjkl
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" ===========
" Input
" ===========
set backspace=indent,eol,start

" タブ入力を複数の空白入力に置き換える
set expandtab
" Vimが挿入するインデントの幅(autoindent等)
set shiftwidth=4

" ===========
" Status Line
" ===========
set laststatus=2

" ===========
" View
" ===========
" タブ文字の表示幅
set tabstop=4

" ===========
" Search
" ===========
" 検索ワードの最初の文字を入力した時点で検索を開始する
set incsearch
" 検索結果をハイライト表示する
set hlsearch
set ignorecase

" ===========
" Color
" ===========
syntax enable
set background=dark
colorscheme slate

" ======================
" Clipboard (Mac OS Only)
" ======================
let s:OSTYPE = system('uname')
if s:OSTYPE == "Darwin\n"
  set clipboard+=unnamed
endif

" ===========
" Twig
" ===========
autocmd BufNewFile,BufRead *.twig set filetype=html
