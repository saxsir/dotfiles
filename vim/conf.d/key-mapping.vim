scriptencoding utf-8

" ===================
" Key mapping configuration
" ===================

" jjでエスケープ
inoremap jj <ESC>

" ctrl+eでNERDTreeを開く
nnoremap <C-e> :NERDTreeToggle<CR>

" ctrl+kで複数行コメントアウト
nmap <C-K> <Plug>(caw:i:toggle)
vmap <C-K> <Plug>(caw:i:toggle)

" ノーマルモード時だけ ; と : を入れ替える(USキーボード仕様)
nnoremap ; :
nnoremap : ;

" reload vimrc
noremap <C-c><C-e>e :edit $HOME/.vimrc<CR>
noremap <C-c><C-e>s :source $HOME/.vimrc<CR>

" ======
" scala
" ======
" scalaはセミコロン使わないので ; と : を入れ替える
autocmd vimrc BufNewFile,BufRead *.scala inoremap ; :
autocmd vimrc BufNewFile,BufRead *.scala inoremap : ;

" scalaはダブルコーテーションの方が使うので ' と " を入れ替える
autocmd vimrc BufNewFile,BufRead *.scala inoremap ' "
autocmd vimrc BufNewFile,BufRead *.scala inoremap " '

echo "Read key mapping configuration"
