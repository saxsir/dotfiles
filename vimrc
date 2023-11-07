" ======================
" vim configuration file
" @author saxsir (https://github.com/saxsir)
" ======================

"==========================
" language
"==========================
set encoding=utf-8
set fileformats=unix,mac,dos

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
colorscheme industry

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

" git commit時はプラグイン読み込まない
if $HOME != $USERPROFILE && $GIT_EXEC_PATH != ''
    finish
end

" plugin読み込み
" use https://github.com/junegunn/vim-plug
call plug#begin("~/.vim/plugged")

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
" Plug 'tpope/vim-fugitive'
Plug 'majutsushi/tagbar'
Plug 'tyru/open-browser.vim'
Plug 'tyru/open-browser-github.vim'
Plug 'simeji/winresizer'
Plug 'mattn/gist-vim' | Plug 'mattn/webapi-vim'
" Plug 'moznion/hateblo.vim' | Plug 'mattn/webapi-vim'
" Plug 'zxqfl/tabnine-vim'
Plug 'editorconfig/editorconfig-vim'

Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

" golang
Plug 'fatih/vim-go', {'for': 'go', 'do': ':GoUpdateBinaries'}

" lsp
Plug 'prabirshrestha/async.vim'
Plug 'prabirshrestha/vim-lsp'
Plug 'prabirshrestha/asyncomplete.vim'
Plug 'prabirshrestha/asyncomplete-lsp.vim'

" html
Plug 'mattn/emmet-vim', {'for': 'html' }

" js
Plug 'prettier/vim-prettier', {
  \ 'do': 'npm install',
  \ 'for': ['javascript', 'typescript', 'css', 'less', 'scss', 'json', 'graphql', 'markdown', 'vue', 'yaml', 'html'] }

Plug 'maksimr/vim-jsbeautify', {
  \ 'do': 'npm install',
  \ 'for': ['javascript', 'typescript', 'css', 'less', 'scss', 'json', 'graphql', 'markdown', 'vue', 'yaml', 'html'] }

" markdown
Plug 'tpope/vim-markdown'
Plug 'kannokanno/previm'

call plug#end()
" Automatically executes filetype plugin indent on and syntax enable. by vim-plug
" syntax on
" filetype plugin indent on

" 各種設定の読み込み


"==========================
" caw
"==========================
map <Leader>c <Plug>(caw:hatpos:toggle)
map <Leader>a <Plug>(caw:dollarpos:toggle)

"==========================
" junkfile
"==========================
let g:junkfile#directory = $HOME . '/src/github.com/saxsir/memo'
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
let g:go_def_mode='gopls'

"==========================
" tagbar
"==========================
noremap <leader>t :<c-u>TagbarToggle<cr>

"==========================
" ctrlp-ghq
"==========================
noremap <leader>g :<c-u>CtrlPGhq<cr>
let ctrlp_ghq_default_action = 'e'

"==========================
" gist-vim
"==========================
let g:gist_clip_command = 'pbcopy'
let g:gist_open_browser_after_post = 1
let g:gist_post_private = 1

"==========================
" golang
"==========================
if executable('gopls')
    au User lsp_setup call lsp#register_server({
        \ 'name': 'gopls',
        \ 'cmd': {server_info->['gopls', '-mode', 'stdio']},
        \ 'whitelist': ['go'],
        \ })
    autocmd FileType go setlocal omnifunc=lsp#complete
endif

"==========================
" autocomplete
"==========================
inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
" inoremap <expr> <cr>    pumvisible() ? "\<C-y>" : "\<cr>"
let g:lsp_async_completion = 1

"==========================
" vim-markdown, previm
"==========================
autocmd BufRead,BufNewFile *.md set filetype=markdown
let g:vim_markdown_folding_disabled=1
let g:previm_enable_realtime = 1

"==========================
" vim-prettier
"==========================
let g:prettier#autoformat = 1
nmap <Leader>f <Plug>(Prettier)

"==========================
" js-beautify
"==========================
" map <c-f> :call JsBeautify()<cr>
autocmd FileType javascript vnoremap <buffer> <c-j> :call RangeJsBeautify()<cr>

"==========================
" fzf-vim
"==========================
" git grep w/ fzf
command! -bang -nargs=* GGrep
  \ call fzf#vim#grep(
  \   'git grep --line-number -- '.shellescape(<q-args>), 0,
  \   fzf#vim#with_preview({'dir': systemlist('git rev-parse --show-toplevel')[0]}), <bang>0)

" rg w/ fzf
function! RipgrepFzf(query, fullscreen)
  let command_fmt = 'rg --column --line-number --no-heading --color=always --smart-case -- %s || true'
  let initial_command = printf(command_fmt, shellescape(a:query))
  let reload_command = printf(command_fmt, '{q}')
  let spec = {'options': ['--phony', '--query', a:query, '--bind', 'change:reload:'.reload_command]}
  call fzf#vim#grep(initial_command, 1, fzf#vim#with_preview(spec), a:fullscreen)
endfunction

command! -nargs=* -bang RG call RipgrepFzf(<q-args>, <bang>0)

nnoremap <silent> <Leader>gg :GGrep<CR>
nnoremap <silent> <Leader>rg :RG<CR>
