" Skip initialization for vim-tiny or vim-small.
if !1 | finish | endif

" dein本体の自動インストール
let s:cache_home = empty($XDG_CACHE_HOME) ? expand('~/.cache') : $XDG_CACHE_HOME
let s:dein_dir = s:cache_home . '/dein'
let s:dein_repo_dir = s:dein_dir . '/repos/github.com/Shougo/dein.vim'
if !isdirectory(s:dein_repo_dir)
  call system('git clone git@github.com:Shougo/dein.vim.git ' . shellescape(s:dein_repo_dir))
endif
let &runtimepath = s:dein_repo_dir .",". &runtimepath

" プラグイン読み込み
let s:toml_file = expand('~/.vim/vimrc.d/plugins/dein.toml')
if dein#load_state(s:dein_dir)
  call dein#begin(s:dein_dir, [$MYVIMRC, s:toml_file])
  call dein#load_toml(s:toml_file)
  call dein#end()
  call dein#save_state()    " キャッシュ作成
endif

" プラグインの自動インストール
if has('vim_starting') && dein#check_install()
  call dein#install()
endif

" プラグインに依存していない設定の読み込み
runtime! vimrc.d/*.vim

" プラグイン関連の設定読み込み
runtime! vimrc.d/plugins/*.vim

syntax on
filetype plugin indent on
