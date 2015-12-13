NeoBundle 'maksimr/vim-jsbeautify'
autocmd FileType html noremap <buffer> <Leader>f :call HtmlBeautify()<cr>
autocmd FileType css noremap <buffer> <Leader>f :call CSSBeautify()<cr>
autocmd FileType javascript noremap <buffer>  <Leader>f :call JsBeautify()<cr>
autocmd FileType html vnoremap <buffer> <Leader>f :call RangeHtmlBeautify()<cr>
autocmd FileType css vnoremap <buffer> <Leader>f :call RangeCSSBeautify()<cr>
autocmd FileType javascript vnoremap <Leader>f :call RangeJsBeautify()<cr>
