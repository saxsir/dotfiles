" 基本的にはここに使っているプラグインとその設定を書く
" 長いやつは別ファイルに分ける

" コメントアウトを簡単に
NeoBundle 'tyru/caw.vim'
nmap <Leader>c <Plug>(caw:i:toggle)
vmap <Leader>c <Plug>(caw:i:toggle)
nmap <Leader>a <Plug>(caw:a:toggle)

" 爆速HTMLコーディング
NeoBundle 'mattn/emmet-vim'

" ファイルのインデントを可視化
NeoBundle 'Yggdroot/indentLine'

" 適当なファイルをすぐつくる
NeoBundle 'Shougo/junkfile.vim'

" 貼り付け時は自動でペーストモード
NeoBundle 'ConradIrwin/vim-bracketed-paste'

" 選択したテキストを囲う
NeoBundle 'tpope/vim-surround'

" 行末の空白を可視化
NeoBundle 'bronson/vim-trailing-whitespace'
