" ==============================
" Extra configuration for Mac OS
" =============================

let OSTYPE = system('uname')

if OSTYPE == "Darwin\n"
  " クリップボード連携
  set clipboard+=unnamed

  echo "Read extra configuration for mac"
endif

unlet OSTYPE
