
" gistに即アップロード
" call dein#add('mattn/gist-vim', {'depends': 'mattn/webapi-vim'})

" asynchronous execution library for Vim
" call dein#add('Shougo/vimproc', {
"           \ 'build': {
"           \     'windows': 'tools\\update-dll-mingw',
"           \     'cygwin': 'make -f make_cygwin.mak',
"           \     'mac': 'make -f make_mac.mak',
"           \     'linux': 'make',
"           \     'unix': 'gmake'}})


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
