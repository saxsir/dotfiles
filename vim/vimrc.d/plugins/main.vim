" 基本的にはここに使っているプラグインとその設定を書く
" 長いやつは別ファイルに分ける

" コメントアウトを簡単に
call dein#add('tyru/caw.vim')
nmap <Leader>c <Plug>(caw:i:toggle)
vmap <Leader>c <Plug>(caw:i:toggle)
nmap <Leader>a <Plug>(caw:a:toggle)

" 爆速HTMLコーディング
call dein#add('mattn/emmet-vim')

" ファイルのインデントを可視化
call dein#add('Yggdroot/indentLine')

" 適当なファイルをすぐつくる
call dein#add('Shougo/junkfile.vim')

" 貼り付け時は自動でペーストモード
call dein#add('ConradIrwin/vim-bracketed-paste')

" 選択したテキストを囲う
call dein#add('tpope/vim-surround')

" 行末の空白を可視化
call dein#add('bronson/vim-trailing-whitespace')
