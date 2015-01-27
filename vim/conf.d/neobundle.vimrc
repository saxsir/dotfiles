scriptencoding utf-8

" ===============================
" neobundleによるプラグインの管理
" ===============================
" Skip initialization for vim-tiny or vim-small.
if !1 | finish | endif

if has('vim_starting')
  set runtimepath+=~/.vim/bundle/neobundle.vim/
endif

call neobundle#begin(expand('~/.vim/bundle/'))

" Let NeoBundle manage NeoBundle
NeoBundleFetch 'Shougo/neobundle.vim'

" ファイルをtree表示してくれる
NeoBundle 'scrooloose/nerdtree'

" 行末の半角スペースを可視化
NeoBundle 'bronson/vim-trailing-whitespace'

" 複数行コメントアウト
NeoBundle 'tyru/caw.vim.git'

" 色をよしなに
NeoBundle 'altercation/vim-colors-solarized'

" ステータスラインをよしなに
NeoBundle 'itchyny/lightline.vim'

call neobundle#end()

" If there are uninstalled bundles found on startup, this will conveniently prompt you to install them.
NeoBundleCheck

echo "Read neobundle configuration"
