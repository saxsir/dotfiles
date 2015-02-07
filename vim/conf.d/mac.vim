scriptencoding utf-8

" ==============================
" Extra configuration for Mac OS
" =============================

let s:OSTYPE = system('uname')

if s:OSTYPE == "Darwin\n"
  " クリップボード連携
  set clipboard+=unnamed

  " echo "Read extra configuration for mac"
endif
