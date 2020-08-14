let NERDTreeShowHidden=1
if exists('g:rg#options')
    call add(g:rg#options, '--no-ignore')
    call add(g:rg#options, '--hidden')
endif
