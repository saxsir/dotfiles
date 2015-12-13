augroup filetypedetect
  autocmd!
  autocmd BufNewFile,BufRead gemrc set filetype=ruby
  autocmd BufNewFile,BufRead gitconfig set filetype=dosini
  autocmd BufNewFile,BufRead tmux.conf set filetype=tmux
  autocmd BufNewFile,BufRead vimperatorrc set filetype=vim
  autocmd BufNewFile,BufRead *.twig set filetype=html
augroup END
