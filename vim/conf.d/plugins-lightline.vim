scriptencoding utf-8

" ===================
" lightline configuration
" ===================

let g:lightline = {
      \ 'colorscheme': 'solarized_dark',
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ],
      \             [ 'readonly', 'absolutepath', 'modified' ] ]
      \ },
      \ 'component': {
      \   'readonly': '%{&readonly?"[read only]":""}',
      \ },
      \ 'separator': { 'left': '', 'right': '' },
      \ 'subseparator': { 'left': '', 'right': '' }
      \ }

" let g:nayn_modoki_animation_enabled= 1
" let g:nyan_modoki_select_cat_face_number = 2

" echo "Read [plugin] lightline configuration"
