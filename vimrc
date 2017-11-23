" ======================
" vim configuration file
" @author saxsir (https://github.com/saxsir)
" ======================

" use https://github.com/junegunn/vim-plug
call plug#begin()

Plug 'mattn/sonictemplate-vim'
Plug 'Shougo/junkfile.vim'
Plug 'Shougo/vimproc.vim', {'do': 'make'}
Plug 'bronson/vim-trailing-whitespace'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'mattn/ctrlp-ghq'
Plug 'itchyny/lightline.vim'
Plug 'thinca/vim-quickrun'
Plug 'tyru/caw.vim'
Plug 'justinmk/vim-dirvish'
Plug 'Yggdroot/indentLine'

" golang
Plug 'fatih/vim-go', {'for': 'go'}
Plug 'nsf/gocode', { 'rtp': 'vim', 'do': '~/.vim/plugged/gocode/vim/symlink.sh', 'for': 'go'}

Plug 'tpope/vim-fugitive'
Plug 'majutsushi/tagbar'
Plug 'tyru/open-browser.vim'
Plug 'tyru/open-browser-github.vim'
Plug 'simeji/winresizer'

call plug#end()

" Automatically executes filetype plugin indent on and syntax enable. by vim-plug
" syntax on
" filetype plugin indent on

"==========================
" language
"==========================
set encoding=utf-8
set fileformats=unix,dos,mac

"==========================
" input
"==========================
set expandtab    " タブを複数のスペースに置き換える
set tabstop=4    " タブ文字の幅
set shiftwidth=2    " 自動インデント幅
set backspace=indent,eol,start    " バックスペースで文字削除

"==========================
" clipboard
"==========================
set clipboard+=unnamed    " クリップボード連携

"==========================
" programming
"==========================
set foldmethod=syntax
set foldlevel=1

"==========================
" color, visual
"==========================
set laststatus=2    " ステータスラインを常に表示
set background=dark
colorscheme slate

"==========================
" backup
"==========================
set hidden
set backup
set backupdir=$HOME/.vimback
set directory=$HOME/.vimtmp
set history=10000
set updatetime=500
set undofile    " vim終了してもundoできるように
set undodir=$HOME/.vimundo

"==========================
" key bind
"==========================
let mapleader = ","
" reload vimrc
nnoremap <C-c><C-e>e :edit $HOME/.vimrc<CR>
nnoremap <C-c><C-e>s :source $MYVIMRC<CR>

" when move to search results, move to center.
noremap n nzz
noremap N Nzz
noremap * *zz
noremap # #zz
noremap g* g*zz
noremap g# g#zz

inoremap jj <ESC>
nnoremap ; :

" splitの移動を簡単に。ctrl押しながらhjkl
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" アクティブなファイルが含まれるディレクトリを展開
cnoremap <expr> %% getcmdtype() == ':' ? expand('%:h').'/' : '%%'

" 編集しているファイル名をコピー
function! g:CopyFilePath()
    let @* = expand("%:p")
    echo @*
endfunction
command! CopyFilePath :call g:CopyFilePath()

"==========================
" caw
"==========================
map <Leader>c <Plug>(caw:hatpos:toggle)
map <Leader>a <Plug>(caw:a:toggle)

"==========================
" junkfile
"==========================
let g:junkfile#directory = $HOME . '/.memo'
command! -nargs=0 DailyLog call junkfile#open_immediately(
      \ strftime('%Y-%m-%d.md'))

"==========================
" lightline
"==========================
let g:lightline = {
      \ 'colorscheme': 'solarized',
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ],
      \             [ 'fugitive', 'readonly', 'absolutepath', 'modified' ] ]
      \ },
      \ 'component': {
      \   'readonly': '%{&readonly?"[read only]":""}',
      \   'fugitive': '[%{exists("*fugitive#head")?fugitive#head():""}]'
      \ },
      \ 'separator': { 'left': '', 'right': '' },
      \ 'subseparator': { 'left': '', 'right': '' }
      \ }

"==========================
" sonictemplate
"==========================
let g:sonictemplate_vim_template_dir = [
      \ '$HOME/.vim/template',
      \]

"==========================
" vim-go debug
"==========================
set updatetime=200

"==========================
" tagbar
"==========================
noremap <leader>t :<c-u>TagbarToggle<cr>

"==========================
" ctrlp-ghq
"==========================
noremap <leader>g :<c-u>CtrlPGhq<cr>
let ctrlp_ghq_default_action = 'e'
