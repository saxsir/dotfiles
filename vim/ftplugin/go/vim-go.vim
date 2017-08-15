" run :GoBuild or :GoTestCompile based on the go file
function! s:build_go_files()
  let l:file = expand('%')
  if l:file =~# '^\f\+_test\.go$'
    call go#cmd#Test(0, 1)
  elseif l:file =~# '^\f\+\.go$'
    call go#cmd#Build(0)
  endif
endfunction

nmap <Leader>r <Plug>(go-run)
nmap <Leader>b :<C-u>call <SID>build_go_files()<CR>
" nmap <Leader>t <Plug>(go-test)
" nmap <Leader>c <Plug>(go-coverage-toggle)

map <C-n> :cnext<CR>
map <C-m> :cprevious<CR>
" nmap <Leader>a :cclose<CR>

let g:go_fmt_command = "goimports"
" let g:go_fmt_fail_silently = 1
let g:go_highlight_build_constraints = 1

" let g:go_highlight_functions = 1
" let g:go_highlight_methods = 1
" let g:go_highlight_fields = 1
" let g:go_highlight_types = 1
" let g:go_highlight_operators = 1
" let g:go_highlight_generate_tags = 1

let g:go_metalinter_enabled = ['vet', 'golint', 'errcheck']
let g:go_highlight_build_constraints = 1
" let g:go_metalinter_autosave = 1
" let g:go_metalinter_autosave_enabled = ['vet', 'golint']

let g:go_def_mapping_enabled = 'godef'
let g:go_def_reuse_buffer=1
nmap gd <Plug>(go-def)
nmap gv <Plug>(go-def-vertical)
nmap gs <Plug>(go-def-split)
nmap gi <Plug>(go-info)
" nmap <Leader>gd <Plug>(go-doc)

let g:go_play_browser_command = "chrome"
