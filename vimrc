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

" scalaのシンタックス
NeoBundle "derekwyatt/vim-scala"

" markdownのシンタックス
NeoBundle "godlygeek/tabular"
NeoBundle "plasticboy/vim-markdown"

" 複数行コメントアウト
NeoBundle "tyru/caw.vim.git"

" phpのシンタックス
NeoBundle "2072/PHP-Indenting-for-VIm"

" slimのシンタックス
NeoBundle "evidens/vim-twig"

" 入力補助
NeoBundle 'Shougo/neocomplcache.git'

" gitる
NeoBundle 'tpope/vim-fugitive'

" coffee-scriptのシンタックス
NeoBundle 'kchmck/vim-coffee-script'

" html5
NeoBundle 'othree/html5.vim'

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

" 隠しファイルをデフォルトで表示させる
let NERDTreeShowHidden = 1

" デフォルトでツリーを表示させる
" 邪魔だったから消す
" autocmd VimEnter * execute 'NERDTree'

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

" jsのインデント
" In Brief Mode script will not indent more than one shiftwidth each line.
" http://www.vim.org/scripts/script.php?script_id=3227
let g:SimpleJsIndenter_BriefMode = 1

" 入力候補の補完
let g:neocomplcache_enable_at_startup = 1
let g:neocomplcache_enable_smart_case = 1
let g:neocomplcache_min_syntax_length = 3
let g:neocomplcache_dictionary_filetype_lists = {
  \ 'default' : '',
  \ 'scala' : $HOME . '/.vim/dict/scala.dict',
  \ }

" カッコ補完
inoremap { {}<Left>
inoremap ( ()<Left>
inoremap [ []<Left>
inoremap { {}<Left>
" inoremap < <><Left>
inoremap " ""<Left>
inoremap ' ''<Left>
inoremap {<Enter> {}<Left><CR><ESC><S-o>
inoremap [<Enter> []<Left><CR><ESC><S-o>
inoremap (<Enter> ()<Left><CR><ESC><S-o>

" ========
" 検索機能
" ========
" 検索ワードの最初の文字を入力した時点で検索を開始する
set incsearch
" 検索結果をハイライト表示する
set hlsearch
" 選択した部分を検索
" vnoremap * "zy;let @/ = @z<CR>n

" ======
" scala
" ======
" scalaはセミコロン使わないので ; と : を入れ替える
autocmd BufNewFile,BufRead *.scala inoremap ; :
autocmd BufNewFile,BufRead *.scala inoremap : ;

" =============
" coffee-script
" =============
autocmd BufNewFile,BufRead *.coffee inoremap ; :
autocmd BufNewFile,BufRead *.coffee inoremap : ;

" ====================
" オレオレキー割り当て
" ====================
" jj でエスケープ
imap jj <Esc>

" ctrl+eでNERDTreeを開く
nnoremap <C-e> :NERDTreeToggle<CR>

" ctrl+kで複数行コメントアウト
nmap <C-K> <Plug>(caw:i:toggle)
vmap <C-K> <Plug>(caw:i:toggle)

" ノーマルモード時だけ ; と : を入れ替える
nnoremap ; :
nnoremap : ;

" reload vimrc
noremap <C-c><C-e>e :edit $HOME/.vimrc<CR>
noremap <C-c><C-e>s :source $HOME/.vimrc<CR>

" neocomplcache
" 前回行われた補完をキャンセル。補完した文字を消す
inoremap <expr><C-g>     neocomplcache#undo_completion()
" 補完候補の中から、共通する部分を補完
inoremap <expr><C-l>     neocomplcache#complete_common_string()
" 補完候補の選択
inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"
" 補完キャンセル
inoremap <expr><C-h> neocomplcache#smart_close_popup()."\<C-h>"
inoremap <expr><BS> neocomplcache#smart_close_popup()."\<C-h>"
inoremap <expr><C-y>  neocomplcache#close_popup()

" ==================================================
" 最後の方に書いといた方がいい処理
" ==================================================
" http://d.hatena.ne.jp/wiredool/20120618/1340019962
" filetypeの自動検出
filetype on
" Required for neobundle
filetype plugin indent on

" 改行時に自動でコメントが挿入されるのをやめたい
" http://katahirado.hatenablog.com/entry/20090117/1232209418
" http://ysmt.blog21.fc2.com/blog-entry-328.html
" プラグインが全部読み込まれた後に設定しないと上書きされるので最後に記述
autocmd FileType * setlocal formatoptions-=ro
