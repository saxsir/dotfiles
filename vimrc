" ======================
" vim configuration file
" @author saxsir (https://github.com/saxsir)
" ======================

" use https://github.com/junegunn/vim-plug
call plug#begin()

" Plug 'mattn/benchvimrc-vim'
" Plug 'mattn/emmet-vim'
" Plug 'mattn/gist-vim'
Plug 'mattn/sonictemplate-vim'
" Plug 'mattn/webapi-vim', {'on': 'Gist'}
Plug 'Shougo/junkfile.vim'
" Plug 'Shougo/vimproc.vim', {'do': 'make'}
Plug 'bronson/vim-trailing-whitespace'
Plug 'Chiel92/vim-autoformat'
" Plug 'ConradIrwin/vim-bracketed-paste'
Plug 'ctrlpvim/ctrlp.vim' | Plug 'mattn/ctrlp-ghq'
" Plug 'haya14busa/incsearch.vim'
Plug 'itchyny/lightline.vim'
" Plug 'LeafCage/yankround.vim'
Plug 'thinca/vim-quickrun'
Plug 'tyru/caw.vim'
Plug 'justinmk/vim-dirvish'
Plug 'Yggdroot/indentLine'

" for each languages
Plug 'fatih/vim-go', {'for': 'go'}
Plug 'AndrewRadev/splitjoin.vim', {'for': 'go'}
Plug 'SirVer/ultisnips'
Plug 'nsf/gocode', { 'rtp': 'vim', 'do': '~/.vim/plugged/gocode/vim/symlink.sh', 'for': 'go'}
" Plug 'vim-ruby/vim-ruby', {'for': 'ruby'}
" Plug 'vim-php/tagbar-phpctags.vim', {'for': 'php'}
" Plug 'shawncplus/phpcomplete.vim', {'for': 'php'}
" Plug 'sumpygump/php-documentor-vim', {'for': 'php'}
" Plug '2072/PHP-Indenting-for-VIm', {'for': 'php'}
Plug 'derekwyatt/vim-scala', {'for': 'scala'}
Plug 'Vimjas/vim-python-pep8-indent', {'for': 'python'}
Plug 'nvie/vim-flake8', {'for': 'python'}
" Plug 'othree/yajs.vim', {'for': 'javascript'}
" Plug 'ekalinin/Dockerfile.vim'
" Plug 'puppetlabs/puppet-syntax-vim'

" unknown
"'altercation/vim-colors-solarized'
"'Modeliner'
Plug 'tpope/vim-fugitive'
"'ShowMarks'
"'mileszs/ack.vim'
Plug 'majutsushi/tagbar'
"'editorconfig/editorconfig-vim'
"'glidenote/memolist.vim'
"'tomtom/tlib_vim'
"'MarcWeber/vim-addon-mw-utils'
"'garbas/vim-snipmate'
"'jszakmeister/markdown2ctags', {'for': 'markdown'}
Plug 'kannokanno/previm', {'for': 'markdown'}
" Plug 'mattn/vim-sqlfmt', {'for': 'sql'}
" Plug 'davidhalter/jedi-vim', {'for': 'python'}
"'nishigori/increment-activator'
Plug 'tyru/open-browser.vim'
Plug 'tyru/open-browser-github.vim'
Plug 'simeji/winresizer'
"'Shougo/neomru.vim'
"'Shougo/unite.vim'
"'Shougo/neocomplete'
"'Shougo/neosnippet'
"'Shougo/neosnippet-snippets'
"'honza/vim-snippets'

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
" vim-autoformat
"==========================
noremap <leader>f :Autoformat<CR>

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
