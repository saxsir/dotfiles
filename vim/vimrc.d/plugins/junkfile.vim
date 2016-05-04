let g:junkfile#directory = $HOME . '/.memo'

command! -nargs=0 DailyLog call junkfile#open_immediately(
    \ strftime('%Y-%m-%d.md'))
