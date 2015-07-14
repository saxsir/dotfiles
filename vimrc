" ======================
" Vim configuration file
" @author saxsir (https://github.com/saxsir)
" ======================
" Skip initialization for vim-tiny or vim-small.
if !1 | finish | endif

filetype off                " required!
filetype plugin indent off

if has('vim_starting')
  if &compatible
    set nocompatible      " Be iMproved
  endif
  set runtimepath+=~/.vim/bundle/neobundle.vim/    " required!
endif

" =============
" Basic Setting
" =============
set backspace=indent,eol,start
set expandtab
set shiftwidth=2
set laststatus=2
set tabstop=4
syntax enable
set background=dark
colorscheme slate
if system('uname') == "Darwin\n"
  set clipboard+=unnamed
endif

" ===========
" Key mapping
" ===========
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
nnoremap <C-t>n  :<C-u>tabnew<CR>
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

" ================================
" Plugins installation (NeoBundle)
" ================================
call neobundle#begin(expand('~/.vim/bundle/'))    " required!
NeoBundleFetch 'Shougo/neobundle.vim'    " required!

" ファイラー
NeoBundle "justinmk/vim-dirvish"

" 開いているディレクトリ以下のファイル検索
NeoBundle "ctrlpvim/ctrlp.vim"

" ローカルリポジトリの検索
" NeoBundle "mattn/ctrlp-ghq"
" noremap <leader>g :<c-u>CtrlPGhq<cr>

" ステータスラインをカスタマイズ
NeoBundle 'itchyny/lightline.vim'
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

" 入力補完
NeoBundle has('lua') ? 'Shougo/neocomplete' : 'Shougo/neocomplcache'
function! s:set_neo_complete_config ()
  let g:neocomplete#enable_at_startup = 1
  let g:neocomplete#enable_ignore_case = 1
  let g:neocomplete#enable_smart_case = 1
  let g:neocomplete#sources#syntax#min_keyword_length = 3
  if !exists('g:neocomplete#keyword_patterns')
    let g:neocomplete#keyword_patterns = {}
  endif
  let g:neocomplete#keyword_patterns._ = '\h\w*'
  inoremap <expr><C-g>     neocomplete#undo_completion()
  inoremap <expr><C-l>     neocomplete#complete_common_string()

  " Recommended key-mappings.
  " <CR>: close popup and save indent.
  inoremap <silent> <CR> <C-r>=<SID>my_cr_function()<CR>
  function! s:my_cr_function()
    return neocomplete#close_popup() . "\<CR>"
  endfunction
  " <TAB>: completion.
  inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"
  " <C-h>, <BS>: close popup and delete backword char.
  inoremap <expr><C-h> neocomplete#smart_close_popup()."\<C-h>"
  inoremap <expr><BS> neocomplete#smart_close_popup()."\<C-h>"
  inoremap <expr><C-y>  neocomplete#close_popup()
  inoremap <expr><C-e>  neocomplete#cancel_popup()
  " Enable omni completion.
  autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
  autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
  autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
  autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
  autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags
endfunction

function! s:set_neo_complcache_config ()
  let g:neocomplcache_enable_at_startup = 1
  let g:neocomplcache_enable_ignore_case = 1
  let g:neocomplcache_enable_smart_case = 1
  if !exists('g:neocomplcache_keyword_patterns')
    let g:neocomplcache_keyword_patterns = {}
  endif
  let g:neocomplcache_keyword_patterns._ = '\h\w*'
  let g:neocomplcache_enable_camel_case_completion = 1
  let g:neocomplcache_enable_underbar_completion = 1
  inoremap <expr><C-g>     neocomplcache#undo_completion()
  inoremap <expr><C-l>     neocomplcache#complete_common_string()

  " Recommended key-mappings.
  " <CR>: close popup and save indent.
  inoremap <silent> <CR> <C-r>=<SID>my_cr_function()<CR>
  function! s:my_cr_function()
    return neocomplcache#smart_close_popup() . "\<CR>"
  endfunction
  " <TAB>: completion.
  inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"
  " <C-h>, <BS>: close popup and delete backword char.
  inoremap <expr><C-h> neocomplcache#smart_close_popup()."\<C-h>"
  inoremap <expr><BS> neocomplcache#smart_close_popup()."\<C-h>"
  inoremap <expr><C-y>  neocomplcache#close_popup()
  inoremap <expr><C-e>  neocomplcache#cancel_popup()
  " Enable omni completion.
  autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
  autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
  autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
  autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
  autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags
endfunction

if neobundle#is_installed('neocomplete')
  call s:set_neo_complete_config ()
elseif neobundle#is_installed('neocomplcache')
  call s:set_neo_complcache_config()
endif

" スニペット
NeoBundle 'Shougo/neosnippet'
NeoBundle 'Shougo/neosnippet-snippets'
NeoBundle 'honza/vim-snippets'
imap <C-k>  <Plug>(neosnippet_expand_or_jump)
smap <C-k>  <Plug>(neosnippet_expand_or_jump)
xmap <C-k>  <Plug>(neosnippet_expand_target)
imap <expr><TAB> neosnippet#expandable_or_jumpable() ?
      \ "\<Plug>(neosnippet_expand_or_jump)"
      \: pumvisible() ? "\<C-n>" : "\<TAB>"
smap <expr><TAB> neosnippet#expandable_or_jumpable() ?
      \ "\<Plug>(neosnippet_expand_or_jump)"
      \: "\<TAB>"
" let g:neosnippet#snippets_directory = '$HOME/.vim/bundle/vim-snippets/snippets'

" 検索
NeoBundle 'haya14busa/incsearch.vim'
set hlsearch
set ignorecase
map /  <Plug>(incsearch-forward)
map ?  <Plug>(incsearch-backward)
map g/ <Plug>(incsearch-stay)
let g:incsearch#auto_nohlsearch = 1
map n  <Plug>(incsearch-nohl-n)
map N  <Plug>(incsearch-nohl-N)
map *  <Plug>(incsearch-nohl-*)
map #  <Plug>(incsearch-nohl-#)
map g* <Plug>(incsearch-nohl-g*)
map g# <Plug>(incsearch-nohl-g#)

" quickrun
NeoBundle 'thinca/vim-quickrun'
let g:quickrun_config = {
\   "_" : {
\       "outputter/buffer/split" : ":botright 8sp",
\       "outputter/buffer/close_on_empty" : 1,
\       "hook/time/enable" : 1
\   },
\}

" コメントアウトを簡単に
NeoBundle 'tyru/caw.vim.git'
nmap <Leader>c <Plug>(caw:i:toggle)
vmap <Leader>c <Plug>(caw:i:toggle)
nmap <Leader>a <Plug>(caw:a:toggle)

" ファイルのインデントを可視化
NeoBundle 'Yggdroot/indentLine'
" 行末の空白を可視化
NeoBundle 'bronson/vim-trailing-whitespace'
" 貼り付け時は自動でペーストモード
NeoBundle 'ConradIrwin/vim-bracketed-paste'
" 選択したテキストを囲う
NeoBundle 'tpope/vim-surround'

" レジスタの履歴を再利用する
NeoBundle 'LeafCage/yankround.vim'
nmap p <Plug>(yankround-p)
xmap p <Plug>(yankround-p)
nmap P <Plug>(yankround-P)
nmap gp <Plug>(yankround-gp)
xmap gp <Plug>(yankround-gp)
nmap gP <Plug>(yankround-gP)
nmap <C-p> <Plug>(yankround-prev)
nmap <C-n> <Plug>(yankround-next)

" html, css, jsの整形
NeoBundle 'maksimr/vim-jsbeautify'
autocmd FileType html noremap <buffer> <Leader>f :call HtmlBeautify()<cr>
autocmd FileType css noremap <buffer> <Leader>f :call CSSBeautify()<cr>
autocmd FileType javascript noremap <buffer>  <Leader>f :call JsBeautify()<cr>
autocmd FileType html vnoremap <buffer> <Leader>f :call RangeHtmlBeautify()<cr>
autocmd FileType css vnoremap <buffer> <Leader>f :call RangeCSSBeautify()<cr>
autocmd FileType javascript vnoremap <Leader>f :call RangeJsBeautify()<cr>

" HTML, CSS
NeoBundle 'othree/html5.vim'
NeoBundle 'hail2u/vim-css3-syntax'
NeoBundle 'mattn/emmet-vim'
" PHP
NeoBundle '2072/PHP-Indenting-for-VIm'
" Twig
autocmd BufNewFile,BufRead *.twig set filetype=html

" NeoBundle 'mattn/sonictemplate-vim'
" NeoBundle 'mattn/gist-vim', {'depends': 'mattn/webapi-vim'}

call neobundle#end()    " required!
filetype plugin indent on    " required!
NeoBundleCheck
