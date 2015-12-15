" とりあえず使ってみるプラグインをここに書く
" 整理するタイミングでよく使ってたらmainに移す

" Provide easy code formatting in Vim by integrating existing code formatters.
NeoBundle "Chiel92/vim-autoformat"
augroup vim-autoformat
  autocmd!
  noremap <Leader>f :Autoformat<CR>
  " autocmd BufWrite * :Autoformat
augroup END

" 開いているディレクトリ以下のファイル検索
" http://qiita.com/oahiroaki/items/d71337fb9d28303a54a8
NeoBundle "ctrlpvim/ctrlp.vim"

" ローカルリポジトリの検索
NeoBundle "mattn/ctrlp-ghq"
noremap <leader>g :<c-u>CtrlPGhq<cr>

" gistに即アップロード
" NeoBundle 'mattn/gist-vim', {'depends': 'mattn/webapi-vim'}

" ファイルタイプ別にテンプレートを選べる
NeoBundle 'mattn/sonictemplate-vim'

" シンプルなファイラー
" NeoBundle "justinmk/vim-dirvish"

" golang
" NeoBundle 'fatih/vim-go'
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
