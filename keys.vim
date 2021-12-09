" ctrl+h/j/k/l to switch windows in vim and tmux 




if ! exists("g:debug")
    let g:debug = 0
endif

" exec "set expandtab?"
if exists("g:keys_loaded")
    finish
endif

let s:up       = 'up'
let s:down     = 'down'
let s:left     = 'left'
let s:right    = 'right'
let s:previous = 'previous'

let g:navigate         = {}
let s:map_check_result = {}
let s:system           = {}

" let g:alternative  = {}
" let g:alternative[s:up]       = 'Up'
" let g:alternative[s:down]     = 'Down'
" let g:alternative[s:left]     = 'Left'
" let g:alternative[s:right]    = 'Right'
" let g:alternative[s:previous] = 'BS'

if ! exists("g:alternative")
    let g:alternative  = {}
endif

let s:system[s:up]       = 'k'
let s:system[s:down]     = 'j'
let s:system[s:left]     = 'h'
let s:system[s:right]    = 'l'
let s:system[s:previous] = 'p'

if ! has_key(g:alternative, s:up) 
    let g:alternative[s:up]       = s:system[s:up]
endif
if ! has_key(g:alternative, s:down)
    let g:alternative[s:down]     = s:system[s:down]
endif
if ! has_key(g:alternative, s:left)
    let g:alternative[s:left]     = s:system[s:left]
endif
if ! has_key(g:alternative, s:right)
    let g:alternative[s:right]    = s:system[s:right]
endif
if ! has_key(g:alternative, s:previous)
    " let g:alternative[s:previous] = s:system[s:previous]
    let g:alternative[s:previous] = '\'
endif

function! keys#tmux_move(direction, navigate)
    let system_key = g:alternative[a:direction]
    if  g:alternative[a:direction] !=? s:system[a:direction]
        let system_key = s:system[a:direction]
    endif

    let wnr = winnr()
    " silent! execute 'wincmd ' . 'C-' . system_key . '<CR>'
    " silent! execute "normal \<C-W>" . "\<C-" . system_key . ">\<CR>"
    " silent! execute 'wincmd ' . system_key . '<CR>'
    silent! execute "normal \<C-W>" . system_key . "\<CR>"
    if 1 == g:debug
        echon "Cursor moved " . a:direction . " "
    endif

    " If the winnr is still the same after we moved, it is the last pane
    if wnr == winnr() && exists('$TMUX')
        if exists("g:loaded_tmux_navigator")
            if 1 == g:debug
                echon "a:navigate['" . a:direction . "'] = " . a:navigate[a:direction]
            endif
            silent! execute a:navigate[a:direction]
        endif
        call system('tmux select-pane -' . tr(system_key, 'phjkl', 'lLDUR'))
    endif
endfunction

function! keys#map_key_ad_hoc(direction, navigate)
    let alternative_key = g:alternative[a:direction]
    let s:map_check_result['<C-' . alternative_key . '>'] =    mapcheck('<C-' . alternative_key . '>', 'n')

    if 1 == g:debug
        echom "mapcheck('<C-" . alternative_key . ">', 'n')      " . mapcheck('<C-' . alternative_key . '>', 'n')
        echom "maparg('<C-" . alternative_key . ">', 'n')        " . maparg('<C-' . alternative_key . '>', 'n')
        echom "s:map_check_result['<C-" . alternative_key . ">'] " . s:map_check_result['<C-' . alternative_key . '>']
    endif
    if s:map_check_result['<C-' . alternative_key . '>'] !~? "tmux_move('" . a:direction. "', g:navigate)"
        let single_key_needs_overriding = 0

        " Don't worry, mapcheck will never return a list
        " for eliment in s:map_check_result['<C-' . alternative_key . '>']
        "     if eliment !~? "tmux_move('" . a:direction. "', g:navigate)"
        "         if s:map_check_result['<C-' . alternative_key . '>'] !=? ""
        "             let single_key_needs_overriding = 1
        "             break
        "         endif
        "     endif
        " endfor

        if s:map_check_result['<C-' . alternative_key . '>'] !=? ""
            let single_key_needs_overriding = 1
            echom "Single key <C-" . alternative_key . " needs overriding"
            if 1 == single_key_needs_overriding
                echohl WarningMsg
                echom "Removing single mapping" . "<C-" . alternative_key . "> " . mapcheck('<C-' . alternative_key . '>', 'n')
                echohl None
                silent! execute 'nunmap <C-' . alternative_key . '>'
            endif
        endif
        if 1 == g:debug
            echom "Establishing single mapping" . "<C-" . alternative_key . "> "
        endif
        " https://gemfury.com/malept/deb:neovim-runtime/-/content/usr/share/nvim/runtime/ftplugin/python.vim
        silent! execute "nnoremap <unique> <silent> <C-" . alternative_key . "> :call keys#tmux_move('" . a:direction . "', g:navigate)<cr>"
        " silent! execute "nmap <unique> <silent> <C-" . alternative_key . "> :call keys#tmux_move('" . a:direction . "', g:navigate)<cr>"
        let s:map_check_result['<C-' . alternative_key . '>'] =    mapcheck('<C-' . alternative_key . '>', 'n')


        if s:map_check_result['<C-' . alternative_key . '>'] =~? "tmux_move('" . a:direction . "', g:navigate)"
            if 1 == g:debug
                echom "Succeeded on mapcheck('<C-" . alternative_key . ">', 'n') " . mapcheck('<C-' . alternative_key . '>', 'n')
                echom "After map, s:map_check_result['<C-" . alternative_key . ">'] " . s:map_check_result['<C-' . alternative_key . '>']
                echom "After map, mapcheck('<C-" . alternative_key . ">', 'n')      " . mapcheck('<C-' . alternative_key . '>', 'n')
                echom "After map, maparg('<C-" . alternative_key . ">', 'n')        " . maparg('<C-' . alternative_key . '>', 'n')
                echom "After map, a:navigate['" . a:direction . "']             " . a:navigate[a:direction]
            endif
        else
            echohl WarningMsg
            echom "Error occurred on " . "mapcheck('<C-" . alternative_key . ">', 'n')"
            echohl None
        endif
    endif


    let s:map_check_result['<C-W><C-' . alternative_key . '>'] =    mapcheck('<C-W><C-' . alternative_key . '>', 'n')
    if 1 == g:debug
        echom "mapcheck('<C-W><C-" . alternative_key . ">', 'n')      " . mapcheck('<C-W><C-' . alternative_key . '>', 'n')
        echom "maparg('<C-W><C-" . alternative_key . ">', 'n')        " . maparg('<C-W><C-' . alternative_key . '>', 'n')
        echom "s:map_check_result['<C-W><C-" . alternative_key . ">'] " . s:map_check_result['<C-W><C-' . alternative_key . '>']
    endif
    if s:map_check_result['<C-W><C-' . alternative_key . '>'] !~? "tmux_move('" . a:direction. "', g:navigate)"
        if s:map_check_result['<C-W><C-' . alternative_key . '>'] !=? ""
            echom "Double key <C-W><C-" . alternative_key . " needs overriding"
            echohl WarningMsg
            echom "Removing double mapping" . "<C-W><C-" . alternative_key . "> " . mapcheck('<C-W><C-' . alternative_key . '>', 'n')
            echohl None
            silent! execute 'nunmap <C-W><C-' . alternative_key . '>'
        endif
        if 1 == g:debug
            echom "Establishing double mapping: " . "<C-W><C-" . alternative_key . "> "
        endif
        silent! execute "nnoremap <unique> <silent> <C-W><C-" . alternative_key . "> :call keys#tmux_move('" . a:direction . "', g:navigate)<cr>"
        " silent! execute "nmap <unique> <silent> <C-W><C-" . alternative_key . "> :call keys#tmux_move('" . a:direction . "', g:navigate)<cr>"
        let s:map_check_result['<C-W><C-' . alternative_key . '>'] =    mapcheck('<C-W><C-' . alternative_key . '>', 'n')


        if s:map_check_result['<C-W><C-' . alternative_key . '>'] =~? "tmux_move('" . a:direction . "', g:navigate)"
            if 1 == g:debug
                echom "Succeeded on mapcheck('<C-W><C-" . alternative_key . ">', 'n') " . mapcheck('<C-W><C-' . alternative_key . '>', 'n')
                echom "After map, s:map_check_result['<C-W><C-" . alternative_key . ">'] " . s:map_check_result['<C-W><C-' . alternative_key . '>']
                echom "After map, mapcheck('<C-W><C-" . alternative_key . ">', 'n')      " . mapcheck('<C-W><C-' . alternative_key . '>', 'n')
                echom "After map, maparg('<C-W><C-" . alternative_key . ">', 'n')        " . maparg('<C-W><C-' . alternative_key . '>', 'n')
                echom "After map, a:navigate['" . a:direction . "']                  " . a:navigate[a:direction]
            endif
        else
            echohl WarningMsg
            echom "Error occurred on " . "mapcheck('<C-" . alternative_key . ">', 'n')"
            echohl None
        endif
    endif


    echom "\n\r" 
    silent! execute '!printf "\n\n"' | redraw!
endfunction

if exists("g:loaded_tmux_navigator") && exists('$TMUX')
    let g:navigate[s:up]       = ':TmuxNavigateUp<cr>'
    let g:navigate[s:down]     = ':TmuxNavigateDown<cr>'
    let g:navigate[s:left]     = ':TmuxNavigateLeft<cr>'
    let g:navigate[s:right]    = ':TmuxNavigateRight<cr>'
    let g:navigate[s:previous] = ':TmuxNavigatePrevious<cr>'
else
    let g:navigate[s:up]       = ':<Nop>'
    let g:navigate[s:down]     = ':<Nop>'
    let g:navigate[s:left]     = ':<Nop>'
    let g:navigate[s:right]    = ':<Nop>'
    let g:navigate[s:previous] = ':<Nop>'
endif

call keys#map_key_ad_hoc(s:up,       g:navigate)
call keys#map_key_ad_hoc(s:down,     g:navigate)
call keys#map_key_ad_hoc(s:left,     g:navigate)
call keys#map_key_ad_hoc(s:right,    g:navigate)
call keys#map_key_ad_hoc(s:previous, g:navigate)


" au! VimEnter * call keys#map_key_ad_hoc('k') | call keys#map_key_ad_hoc('j') | call keys#map_key_ad_hoc('h') | call keys#map_key_ad_hoc('l')  



let g:keys_loaded = 1

" How to use hasmapto
" if 1 == hasmapto(":call keys#tmux_move('l', g:navigate)<CR>", 'n')
" endif











