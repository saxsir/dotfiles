" バックスペースで文字削除
set backspace=indent,eol,start

" タブを複数のスペースに置き換える
set expandtab

" タブ文字の幅
set tabstop=4

" 自動インデント幅
set shiftwidth=2

" vim終了してもundoできるように
set undodir=$HOME/.vim/undodir
set undofile

" ステータスバーの表示
set laststatus=2

" 色
set background=dark
colorscheme slate

" Macのみクリップボード連携
if system('uname') == "Darwin\n"
  set clipboard+=unnamed
endif

" fold
set foldmethod=syntax
set foldlevel=1
