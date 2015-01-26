" ============================================
" Basic configuration (Not depends on plugins)
" ============================================

" ================
" Display function
" ================
" 行番号の表示
set number

" タブ文字の表示幅
set tabstop=2

" ================
" Editing function
" ================
" インサートモード時にバックスペースを使う
set backspace=indent,eol,start

" 開いているファイルのディレクトリに自動で移動する
set autochdir

" Vimが挿入するインデントの幅
set shiftwidth=2

" タブ入力を複数の空白入力に置き換える
set expandtab

" 改行時に前の行のインデントを継続する
set autoindent

" ==================
" Searching function
" ==================
" 検索ワードの最初の文字を入力した時点で検索を開始する
set incsearch

" 検索結果をハイライト表示する
set hlsearch

" ==============
" Other function
" ==============
" バックアップディレクトリの指定
if !isdirectory(expand("~/.vimbackup"))
  !mkdir -p ~/.vimbackup
endif
set backupdir=$HOME/.vimbackup

echo "Read basic configuration"
