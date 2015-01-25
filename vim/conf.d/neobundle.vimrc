" ===============================
" neobundleによるプラグインの管理
" ===============================
echo "Read neobundle configuration"

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

call neobundle#end()

" If there are uninstalled bundles found on startup, this will conveniently prompt you to install them.
NeoBundleCheck
