" ======================
" vim configuration file
" ======================

" 挙動を vi 互換ではなく、Vim のデフォルト設定にする
set nocompatible

" zshrcの読み込みに時間がかかるのでbashに変更
set shell=bash\ -i

" 一旦ファイルタイプ関連を無効化する
filetype off
filetype plugin indent off

" ===========
" neobundle系
" ===========
set runtimepath+=~/.vim/bundle/neobundle.vim/

call neobundle#begin(expand('~/.vim/bundle/'))

" Let NeoBundle manage NeoBundle
NeoBundleFetch 'Shougo/neobundle.vim'

" ファイルをtree表示してくれる
NeoBundle 'scrooloose/nerdtree'

" emmet for vim
NeoBundle 'mattn/emmet-vim'

" jsのインデント
NeoBundle 'Simple-Javascript-Indenter'

" 癒やし
NeoBundle 'drillbits/nyan-modoki.vim'

" 色をよしなに
NeoBundle 'altercation/vim-colors-solarized'

" 行末の半角スペースを可視化
NeoBundle 'bronson/vim-trailing-whitespace'

" rustのシンタックス
NeoBundle "wting/rust.vim"

call neobundle#end()

" If there are uninstalled bundles found on startup,
" this will conveniently prompt you to install them.
NeoBundleCheck

" ====================
" 基本設定
" ====================
" バックアップディレクトリの指定
if !isdirectory(expand("~/.vimbackup"))
  !mkdir -p ~/.vimbackup
endif
set backupdir=$HOME/.vimbackup

" インサートモード時にバックスペースを使う
set backspace=indent,eol,start

" ========
" 表示機能
" ========
" 行番号を表示する
set number
" 行番号の色
highlight LineNr ctermfg=darkyellow
" 癒やし
set laststatus=2
set statusline=%{g:NyanModoki()}
let g:nyan_modoki_select_cat_face_number = 2
let g:nayn_modoki_animation_enabled= 1

" カラースキーマ
syntax enable
let g:solarized_termcolors=256
set background=dark
colorscheme solarized
"colorscheme slate

" ========
" 入力機能
" ========
" タブ文字の表示幅
set tabstop=2
" Vimが挿入するインデントの幅
set shiftwidth=2
" タブ入力を複数の空白入力に置き換える
set expandtab
" 改行時に前の行のインデントを継続する
set autoindent

" In Brief Mode script will not indent more than one shiftwidth each line.
" http://www.vim.org/scripts/script.php?script_id=3227
" let g:SimpleJsIndenter_BriefMode = 1

" ========
" 検索機能
" ========
" 検索ワードの最初の文字を入力した時点で検索を開始する
set incsearch
" 検索結果をハイライト表示する
set hlsearch

" ====================
" オレオレキー割り当て
" ====================
" jj でエスケープ
imap jj <Esc>

" ctrl+eでNERDTreeを開く
nnoremap <C-e> :NERDTreeToggle<CR>

" ==================================================
" 最後の方に書いといた方がいい処理
" ==================================================
" http://d.hatena.ne.jp/wiredool/20120618/1340019962
" filetypeの自動検出
filetype on
" Required for neobundle
filetype plugin indent on
