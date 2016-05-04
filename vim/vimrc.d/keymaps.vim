let mapleader = ","

" Reload vimrc
nnoremap <C-c><C-e>e :edit $HOME/.vimrc<CR>
nnoremap <C-c><C-e>s :source $HOME/.vimrc<CR>

" Escape
inoremap jj <ESC>

" For US keyboard
nnoremap ; :
nnoremap : ;

" Tab操作を簡単に。
nnoremap <C-t>  <Nop>
nnoremap <C-t>t  :<C-u>tabnew<CR>
nnoremap <C-t>c  :<C-u>tabclose<CR>
nnoremap <C-t>l :<C-u>execute 'tabnext' 1 + (tabpagenr() + v:count1 - 1) % tabpagenr('$')<CR>
nnoremap <C-t>h  gT

" splitの移動を簡単に。ctrl押しながらhjkl
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" アクティブなファイルが含まれるディレクトリを展開
cnoremap <expr> %% getcmdtype() == ':' ? expand('%:h').'/' : '%%'
