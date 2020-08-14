let NERDTreeShowHidden=1
if exists('g:rg_options')
    call add(g:rg_options, '--no-ignore')
    call add(g:rg_options, '--hidden')
endif
