" Strip trailing whitespace
let whitespace_blacklist = ['diff']
autocmd BufWritePre * if index(whitespace_blacklist, &ft) < 0 | %s/\s\+$//e
