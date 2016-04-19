" とりあえず使ってみるプラグインをここに書く
" 整理するタイミングでよく使ってたらmainに移す

" Provide easy code formatting in Vim by integrating existing code formatters.
call dein#add("Chiel92/vim-autoformat")
augroup vim-autoformat
  autocmd!
  noremap <Leader>f :Autoformat<CR>
  " autocmd BufWrite * :Autoformat
augroup END

" 開いているディレクトリ以下のファイル検索
" http://qiita.com/oahiroaki/items/d71337fb9d28303a54a8
call dein#add("ctrlpvim/ctrlp.vim")

" ローカルリポジトリの検索
call dein#add("mattn/ctrlp-ghq")
noremap <leader>g :<c-u>CtrlPGhq<cr>

" gistに即アップロード
" call dein#add('mattn/gist-vim', {'depends': 'mattn/webapi-vim'})

" ファイルタイプ別にテンプレートを選べる
call dein#add('mattn/sonictemplate-vim')

" asynchronous execution library for Vim
call dein#add('Shougo/vimproc', {
          \ 'build': {
          \     'windows': 'tools\\update-dll-mingw',
          \     'cygwin': 'make -f make_cygwin.mak',
          \     'mac': 'make -f make_mac.mak',
          \     'linux': 'make',
          \     'unix': 'gmake'}})


" シンプルなファイラー
call dein#add('justinmk/vim-dirvish')

" golang
" call dein#add('fatih/vim-go')
" au FileType go nmap <leader>r <Plug>(go-run)
" au FileType go nmap <leader>b <Plug>(go-build)
" au FileType go nmap <leader>t <Plug>(go-test)
" au FileType go nmap <leader>c <Plug>(go-coverage)
" au FileType go nmap <Leader>ds <Plug>(go-def-split)
" au FileType go nmap <Leader>dv <Plug>(go-def-vertical)
" au FileType go nmap <Leader>dt <Plug>(go-def-tab)
" au FileType go nmap <Leader>gd <Plug>(go-doc)
" au FileType go nmap <Leader>gv <Plug>(go-doc-vertical)
" au FileType go nmap <Leader>gb <Plug>(go-doc-browser)
" au FileType go nmap <Leader>s <Plug>(go-implements)
" au FileType go nmap <Leader>i <Plug>(go-info)
" au FileType go nmap <Leader>e <Plug>(go-rename)

"
" call dein#add('kakkyz81/evervim')
" nnoremap <Leader>l :EvervimNotebookList<CR>
" nnoremap <Leader>s :EvervimSearchByQuery<Space>
" nnoremap <Leader>c :EvervimCreateNote<CR>
" nnoremap <Leader>t :EvervimListTags<CR>
"
" refs. http://qiita.com/karur4n/items/a26007236c59c5fb8735
call dein#add('elzr/vim-json')
let g:vim_json_syntax_conceal = 0
