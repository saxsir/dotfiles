" ==============================
" Extra configuration for Mac OS
" =============================

let OSTYPE = system('uname')

if OSTYPE == "Darwin\n"
  echo "Read extra configuration for mac"

  " クリップボード連携
  set clipboard+=unnamed
endif

unlet OSTYPE
