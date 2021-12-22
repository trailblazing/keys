" ctrl+h/j/k/l to switch windows in vim and tmux 




if ! exists("g:keys_debug")
    let g:keys_debug = 0
endif

" exec "set expandtab?"
if exists("g:loaded_keys")
    finish
endif

let s:up       = 'up'
let s:down     = 'down'
let s:left     = 'left'
let s:right    = 'right'
let s:previous = 'previous'

let g:navigate         = {}
" let s:map_check_result = {}
let s:map_arg_result   = {}
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

    let wnr_original = winnr()
    " silent! execute 'wincmd ' . 'C-' . system_key
    " silent! execute "normal \<C-W>" . "\<C-" . system_key . ">\<CR>"
    " silent! execute 'wincmd ' . system_key
    silent! execute "normal \<C-W>" . system_key . "\<CR>"
    if 1 == g:keys_debug
        echon "Cursor moved " . a:direction . " "
    endif

    " If the winnr is still the same after we moved, it is the last pane
    if wnr_original == winnr() && exists('$TMUX')
        if exists("g:loaded_tmux_navigator")
            if 1 == g:keys_debug
                echon "a:navigate['" . a:direction . "'] = " . a:navigate[a:direction]
            endif
            silent! execute a:navigate[a:direction]
        else
            call system('tmux select-pane -' . tr(system_key, 'phjkl', 'lLDUR'))
        endif
    endif
    redraw!
endfunction

function! keys#map_key_ad_hoc(direction, navigate)
    let alternative_key = g:alternative[a:direction]

    " let s:map_check_result['<C-' . alternative_key . '>'] = mapcheck('<C-' . alternative_key . '>', 'n')
    let s:map_arg_result['<C-' . alternative_key . '>'] = maparg('<C-' . alternative_key . '>', 'n', 'false')

    if 1 == g:keys_debug
        " echom "mapcheck('<C-" . alternative_key . ">', 'n')      " . mapcheck('<C-' . alternative_key . '>', 'n')
        echom "maparg('<C-" . alternative_key . ">', 'n', 'false') " . maparg('<C-' . alternative_key . '>', 'n', 'false')
    endif

    if s:map_arg_result['<C-' . alternative_key . '>'] !~? "tmux_move('" . a:direction. "', g:navigate)"
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

        if s:map_arg_result['<C-' . alternative_key . '>'] !=? ""
            let single_key_needs_overriding = 1
            " echom "Single key <C-" . alternative_key . "> needs overriding"
            if 1 == single_key_needs_overriding
                echohl WarningMsg
                echom "Single mapping " . "<C-" . alternative_key . "> " . mapcheck('<C-' . alternative_key . '>', 'n') . " has been removed."
                echohl None
                silent! execute 'nunmap <C-' . alternative_key . '>'
            endif
        endif
        if 1 == g:keys_debug
            echom "Establishing single mapping" . "<C-" . alternative_key . "> "
        endif
        " https://gemfury.com/malept/deb:neovim-runtime/-/content/usr/share/nvim/runtime/ftplugin/python.vim
        silent! execute "nnoremap <unique> <silent> <C-" . alternative_key . "> :call keys#tmux_move('" . a:direction . "', g:navigate)<cr>"
        " silent! execute "nmap <unique> <silent> <C-" . alternative_key . "> :call keys#tmux_move('" . a:direction . "', g:navigate)<cr>"

        " let s:map_check_result['<C-' . alternative_key . '>'] = mapcheck('<C-' . alternative_key . '>', 'n')
        let s:map_arg_result['<C-' . alternative_key . '>']   = maparg('<C-' . alternative_key . '>', 'n', 'false')
        if s:map_arg_result['<C-' . alternative_key . '>'] !~? "tmux_move('" . a:direction . "', g:navigate)"
        "     if 1 == g:keys_debug
        "         echom "Succeeded on mapcheck('<C-" . alternative_key . ">', 'n') " . mapcheck('<C-' . alternative_key . '>', 'n')
        "         echom "After map, s:map_check_result['<C-" . alternative_key . ">'] " . s:map_check_result['<C-' . alternative_key . '>']
        "         echom "After map, mapcheck('<C-" . alternative_key . ">', 'n')      " . mapcheck('<C-' . alternative_key . '>', 'n')
        "         echom "After map, maparg('<C-" . alternative_key . ">', 'n')        " . maparg('<C-' . alternative_key . '>', 'n')
        "         echom "After map, a:navigate['" . a:direction . "']             " . a:navigate[a:direction]
        "     endif
        " else
            echohl WarningMsg
            echom "Error occurred on " . "mapcheck('<C-" . alternative_key . ">', 'n')"
            echohl None
        endif
    endif

    if 1 == g:keys_debug
        echom "mapcheck('<C-" . alternative_key . ">', 'n')        " . mapcheck('<C-' . alternative_key . '>', 'n')
        echom "maparg('<C-" . alternative_key . ">', 'n', 'false') " . maparg('<C-' . alternative_key . '>', 'n', 'false')
        " echom "s:map_check_result['<C-" . alternative_key . ">'] " . s:map_check_result['<C-' . alternative_key . '>']
        echom "s:map_arg_result['<C-" . alternative_key . ">'] " . s:map_arg_result['<C-' . alternative_key . '>']
        " echom "a:navigate['" . a:direction . "']             " . a:navigate[a:direction]
    endif

    " let s:map_check_result['<C-W><C-' . alternative_key . '>'] = mapcheck('<C-W><C-' . alternative_key . '>', 'n')
    let s:map_arg_result['<C-W><C-' . alternative_key . '>']        = maparg('<C-W><C-' . alternative_key . '>', 'n', 'false')

    if 1 == g:keys_debug
        " echom "mapcheck('<C-W><C-" . alternative_key . ">', 'n')      " . mapcheck('<C-W><C-' . alternative_key . '>', 'n')
        echom "maparg('<C-W><C-" . alternative_key . ">', 'n', 'false') " . maparg('<C-W><C-' . alternative_key . '>', 'n', 'false')

    endif

    if s:map_arg_result['<C-W><C-' . alternative_key . '>'] !~? "tmux_move('" . a:direction. "', g:navigate)"
        if s:map_arg_result['<C-W><C-' . alternative_key . '>'] !=? ""
            " echom "Double key <C-W><C-" . alternative_key . " needs overriding"
            echohl WarningMsg
            echom "Double mapping " . "<C-W><C-" . alternative_key . "> " . mapcheck('<C-W><C-' . alternative_key . '>', 'n'). " has been removed."
            echohl None
            silent! execute 'nunmap <C-W><C-' . alternative_key . '>'
        endif
        if 1 == g:keys_debug
            echom "Establishing double mapping: " . "<C-W><C-" . alternative_key . "> "
        endif
        silent! execute "nnoremap <unique> <silent> <C-W><C-" . alternative_key . "> :call keys#tmux_move('" . a:direction . "', g:navigate)<cr>"
        " silent! execute "nmap <unique> <silent> <C-W><C-" . alternative_key . "> :call keys#tmux_move('" . a:direction . "', g:navigate)<cr>"

        " let s:map_check_result['<C-W><C-' . alternative_key . '>'] = mapcheck('<C-W><C-' . alternative_key . '>', 'n')
        let s:map_arg_result['<C-W><C-' . alternative_key . '>']   = maparg('<C-W><C-' . alternative_key . '>', 'n', 'false')
        if s:map_arg_result['<C-W><C-' . alternative_key . '>'] !~? "tmux_move('" . a:direction . "', g:navigate)"
        "     if 1 == g:keys_debug
        "         echom "Succeeded on mapcheck('<C-W><C-" . alternative_key . ">', 'n') " . mapcheck('<C-W><C-' . alternative_key . '>', 'n')
        "         echom "After map, s:map_check_result['<C-W><C-" . alternative_key . ">'] " . s:map_check_result['<C-W><C-' . alternative_key . '>']
        "         echom "After map, mapcheck('<C-W><C-" . alternative_key . ">', 'n')      " . mapcheck('<C-W><C-' . alternative_key . '>', 'n')
        "         echom "After map, maparg('<C-W><C-" . alternative_key . ">', 'n')        " . maparg('<C-W><C-' . alternative_key . '>', 'n')
        "         echom "After map, a:navigate['" . a:direction . "']                  " . a:navigate[a:direction]
        "     endif
        " else
            echohl WarningMsg
            echom "Error occurred on " . "mapcheck('<C-" . alternative_key . ">', 'n')"
            echohl None
        endif
    endif

    if 1 == g:keys_debug
        echom "mapcheck('<C-W><C-" . alternative_key . ">', 'n')        " . mapcheck('<C-W><C-' . alternative_key . '>', 'n')
        echom "maparg('<C-W><C-" . alternative_key . ">', 'n', 'false') " . maparg('<C-W><C-' . alternative_key . '>', 'n', 'false')
        " echom "s:map_check_result['<C-W><C-" . alternative_key . ">'] " . s:map_check_result['<C-W><C-' . alternative_key . '>']
        echom "s:map_arg_result['<C-W><C-" . alternative_key . ">'] " . s:map_arg_result['<C-W><C-' . alternative_key . '>']
        echom "a:navigate['" . a:direction . "']                  " . a:navigate[a:direction]
    endif

    if 1 == g:keys_debug
        echom "\n\r" 
        silent! execute '!printf "\n\n"' | redraw!
    endif

endfunction

if exists("g:loaded_tmux_navigator") && exists('$TMUX')
    let g:navigate[s:up]       = ':TmuxNavigateUp'
    let g:navigate[s:down]     = ':TmuxNavigateDown'
    let g:navigate[s:left]     = ':TmuxNavigateLeft'
    let g:navigate[s:right]    = ':TmuxNavigateRight'
    let g:navigate[s:previous] = ':TmuxNavigatePrevious'
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



let g:loaded_keys = 1

" How to use hasmapto
" if 1 == hasmapto(":call keys#tmux_move('l', g:navigate)<CR>", 'n')
" endif











