" ===================
" Key mapping configuration
" ===================
echo "Read key mapping configuration"

" jjでエスケープ
imap jj <ESC>

" ctrl+eでNERDTreeを開く
nnoremap <C-e> :NERDTreeToggle<CR>

" ノーマルモード時だけ ; と : を入れ替える(USキーボード仕様)
nnoremap ; :
nnoremap : ;

" reload vimrc
noremap <C-c><C-e>e :edit $HOME/.vimrc<CR>
noremap <C-c><C-e>s :source $HOME/.vimrc<CR>
