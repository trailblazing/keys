" ctrl+h/j/k/l to switch windows in vim/nvim and tmux

if ! exists("g:_keys_develop")
	let g:_keys_develop = 0
endif

" exec "set expandtab?"
if exists("g:loaded_keys")
	finish
endif

let g:loaded_keys = 1

let s:up	   = 'up'
let s:down	   = 'down'
let s:left	   = 'left'
let s:right    = 'right'
let s:previous = 'previous'

let g:navigate		   = {}
" let s:map_check_result = {}
let s:map_arg_result   = {}
let s:system		   = {}

" let g:preferred_navi	= {}
" let g:preferred_navi[s:up]	   = 'Up'
" let g:preferred_navi[s:down]	   = 'Down'
" let g:preferred_navi[s:left]	   = 'Left'
" let g:preferred_navi[s:right]    = 'Right'
" let g:preferred_navi[s:previous] = 'BS'

if ! exists("g:conflict_resolve")
	let g:conflict_resolve	= {}
endif

if ! exists("g:preferred_navi")
	let g:preferred_navi  = {}
endif

let s:system[s:up]		 = 'k'
let s:system[s:down]	 = 'j'
let s:system[s:left]	 = 'h'
let s:system[s:right]	 = 'l'
let s:system[s:previous] = 'p'

if ! has_key(g:conflict_resolve, s:up)
	let g:conflict_resolve[s:up]	   = ''
endif
if ! has_key(g:conflict_resolve, s:down)
	let g:conflict_resolve[s:down]	   = ''
endif
if ! has_key(g:conflict_resolve, s:left)
	let g:conflict_resolve[s:left]	   = ''
endif
if ! has_key(g:conflict_resolve, s:right)
	" let g:conflict_resolve[s:right]	 = 'm'
	let g:conflict_resolve[s:right]    = ';'
	" let g:conflict_resolve[s:right]	 = '/'
endif
if ! has_key(g:preferred_navi, s:previous)
	let g:conflict_resolve[s:previous] = ''
endif

if ! has_key(g:preferred_navi, s:up)
	let g:preferred_navi[s:up]		 = s:system[s:up]
endif
if ! has_key(g:preferred_navi, s:down)
	let g:preferred_navi[s:down]	 = s:system[s:down]
endif
if ! has_key(g:preferred_navi, s:left)
	let g:preferred_navi[s:left]	 = s:system[s:left]
endif
if ! has_key(g:preferred_navi, s:right)
	let g:preferred_navi[s:right]	 = s:system[s:right]
endif
if ! has_key(g:preferred_navi, s:previous)
	" let g:preferred_navi[s:previous] = s:system[s:previous]
	" ctrl-p might be used for searching
	let g:preferred_navi[s:previous] = '\'
endif

function! keys#tmux_move(direction, navigate)
	let applied_key = g:preferred_navi[a:direction]
	if	g:preferred_navi[a:direction] !=? s:system[a:direction]
		let applied_key = s:system[a:direction]
	endif

	if "" == &buftype && 0 != &modified
		silent! call boot#write_generic()
	endif

	let l:wnr_original = winnr()

	" silent! execute 'wincmd ' . 'C-' . applied_key
	" silent! execute "normal \<C-W>" . "\<C-" . applied_key . ">\<CR>"

	silent! execute 'wincmd ' . applied_key
	" Following command is not the same as above, it wil not switch to read-only buffers
	" silent! execute "normal \<C-W>" . applied_key . "\<CR>"

	if 1 == g:_keys_develop
		echon "Cursor moved " . a:direction . " "
	endif

	" If the winnr is still the same after we moved, it is the last pane
	if l:wnr_original == winnr() && exists('$TMUX')

		" # smart pane switching with awareness of vim splits
		" # https://thoughtbot.com/blog/seamlessly-navigate-vim-and-tmux-splits
		" # # https://github.com/christoomey/vim-tmux-navigator
		" # /mnt/vinit/nvim/init.vim
		" # " let g:vim_packages_use['christoomey/vim-tmux-navigator'] = { 'type' : 'start' }
		" # /mnt/vinit/vim/pack/packager/start/keys/after/plugin/keys.vim
		" # "	  silent! execute(a:navigate[a:direction])
		" # /mnt/tinit/tmux.conf
		" # set -g @plugin 'christoomey/vim-tmux-navigator'

		" if l:wnr_original == winnr()
		"	  \ && exists("g:loaded_tmux_navigator")
		"	  if 1 == g:_keys_develop
		"		  echon "a:navigate['" . a:direction . "'] =
		"			  \ " . a:navigate[a:direction] . " "
		"		  " Error detected while processing function keys#tmux_move:
		"		  " line   25:
		"		  " a:navigate['left'] :TmuxNavigateLeft
		"		  " E171: Missing :endif
		"	  endif
		"	  " silent! execute(a:navigate[a:direction])
		"	  " execute "try\na:navigate[a:direction]\ncatch\nendtry"
		"	  try
		"		  execute(a:navigate[a:direction])
		"	  catch
		"	  endtry
		"	  let l:wnr_original = winnr()
		" endif

		if l:wnr_original == winnr() && ( ! exists('w:focus_lost') || w:focus_lost == 0 )
			if 1 == g:_keys_develop
				echon "tmux select-pane -" . tr(applied_key, 'phjkl', 'lLDUR')
			endif
			if has('nvim')
				" :!tmux select-pane -L
				" open terminal failed: not a terminal
				" silent! execute('!tmux select-pane -' . tr(applied_key, 'phjkl', 'lLDUR'))
				call system(['/usr/bin/tmux', 'select-pane', '-'
					\ . tr(applied_key, 'phjkl', 'lLDUR')])
				call feedkeys("\<CR>")
			else
				call system("sh -c '/usr/bin/tmux select-pane -"
					\ . tr(applied_key, 'phjkl', 'lLDUR') . "'")
				call feedkeys("\<CR>")
			endif
			let l:wnr_original = winnr()
		endif
	endif
	" Time consuming
	" redraw!
endfunction

function! keys#map_key_ad_hoc(direction, navigate)
	let navi_key = g:preferred_navi[a:direction]

	let s:map_arg_result['<C-' . navi_key . '>'] =
		\ maparg('<C-' . navi_key . '>', 'n', 'false')

	if 1 == g:_keys_develop
		echom "maparg('<C-" . navi_key . ">', 'n', 'false') "
			\ . maparg('<C-' . navi_key . '>', 'n', 'false')
		call feedkeys("\<CR>")
	endif

	if s:map_arg_result['<C-' . navi_key . '>'] !~?
		\ "tmux_move('" . a:direction. "', g:navigate)"
		let single_key_needs_overriding = 0

		" Don't worry, mapcheck will never return a list
		" for eliment in s:map_check_result['<C-' . navi_key . '>']
		"	  if eliment !~? "tmux_move('" . a:direction. "', g:navigate)"
		"		  if s:map_check_result['<C-' . navi_key . '>'] !=? ""
		"			  let single_key_needs_overriding = 1
		"			  break
		"		  endif
		"	  endif
		" endfor

		if s:map_arg_result['<C-' . navi_key . '>'] !=? ""
			let single_key_needs_overriding = 1
			" echom "Single key <C-" . navi_key . "> needs overriding"
			if 1 == single_key_needs_overriding
				if g:conflict_resolve[a:direction] != ''
					if g:preferred_navi[a:direction] ==? 'l'
						" For neovim
						" help default-mappings
						" nnoremap <C-L> <Cmd>nohlsearch<Bar>diffupdate<CR><C-L>
						" if s:map_arg_result['<C-' . navi_key . '>'] =~?
						"	  \ "<Cmd>nohlsearch<Bar>diffupdate<CR><C-L>"
						" nnoremap <C-;> <Cmd>nohlsearch<Bar>diffupdate<CR><C-L>
						silent! execute 'nnoremap <C-'
							\ . g:conflict_resolve[a:direction] . '> '
							\ . ':nohlsearch <Bar> diffupdate<CR>'
						" nnoremap <C-m> :nohlsearch <Bar> diffupdate<CR>
						" endif
					else
						silent! execute 'nnoremap <C-'
							\ . g:conflict_resolve[a:direction] . '> '
							\ . mapcheck('<C-' . navi_key . '>', 'n')
					endif
					echohl WarningMsg
					echom "Single mapping " . "<C-" . navi_key . "> "
						\ . mapcheck('<C-' . navi_key . '>', 'n') .
						\ " has been replaced with: \"" . "<C-"
						\ . g:conflict_resolve[a:direction] . "> "
						\ . maparg('<C-' . g:conflict_resolve[a:direction]
						\ . '>', '') .	"\""
					call feedkeys("\<CR>")
					echohl None
				else
					if 1 == g:_keys_develop
						echohl WarningMsg
						echom "Single mapping " . "<C-" . navi_key . "> "
							\ . mapcheck('<C-' . navi_key . '>', 'n') .
							\ " has been removed"
						call feedkeys("\<CR>")
						echohl None
					endif
				endif
				silent! execute 'nunmap <C-' . navi_key . '>'
			endif
		endif
		if 1 == g:_keys_develop
			echom "Establishing single mapping" . "<C-" . navi_key . "> "
			call feedkeys("\<CR>")
		endif
		" https://gemfury.com/malept/deb:neovim-runtime/-/content/usr/share/nvim/runtime/ftplugin/python.vim
		silent! execute "nnoremap <unique> <silent> <C-" . navi_key
			\ . "> :call keys#tmux_move('" . a:direction . "', g:navigate)<cr>"

		let s:map_arg_result['<C-' . navi_key . '>']   =
			\ maparg('<C-' . navi_key . '>', 'n', 'false')
		if s:map_arg_result['<C-' . navi_key . '>'] !~?
			\ "tmux_move('" . a:direction . "', g:navigate)"
			echohl WarningMsg
			echom "Error occurred on " . "mapcheck('<C-" . navi_key . ">', 'n')"
			call feedkeys("\<CR>")
			echohl None
		endif
	endif

	if 1 == g:_keys_develop
		echom "mapcheck('<C-" . navi_key . ">', 'n')		"
			\ . mapcheck('<C-' . navi_key . '>', 'n')
		echom "maparg('<C-" . navi_key . ">', 'n', 'false') "
			\ . maparg('<C-' . navi_key . '>', 'n', 'false')
		echom "s:map_arg_result['<C-" . navi_key . ">'] "
			\ . s:map_arg_result['<C-' . navi_key . '>']
		call feedkeys("\<CR>")
	endif

	let s:map_arg_result['<C-W><C-' . navi_key . '>']
		\ = maparg('<C-W><C-' . navi_key . '>', 'n', 'false')

	if 1 == g:_keys_develop
		echom "maparg('<C-W><C-" . navi_key . ">', 'n', 'false') "
			\ . maparg('<C-W><C-' . navi_key . '>', 'n', 'false')
		call feedkeys("\<CR>")
	endif

	if s:map_arg_result['<C-W><C-' . navi_key . '>'] !~?
		\ "tmux_move('" . a:direction. "', g:navigate)"
		if s:map_arg_result['<C-W><C-' . navi_key . '>'] !=? ""
			if g:conflict_resolve[a:direction] != ''
				silent! execute 'nnoremap <C-W><C-'
					\ . g:conflict_resolve[a:direction] . '> '
					\ . mapcheck('<C-W><C-' . navi_key . '>', 'n')
				echohl WarningMsg
				echom "Single mapping " . "<C-W><C-" . navi_key . "> "
					\ . mapcheck('<C-W><C-' . navi_key . '>', 'n') .
					\ " has been replaced with: \"" . "<C-W><C-"
					\ . g:conflict_resolve[a:direction] . "> "
					\ . maparg('<C-W><C-' . g:conflict_resolve[a:direction]
					\ . '>', '') .	"\""
				call feedkeys("\<CR>")
				echohl None
			else
				if 1 == g:_keys_develop
					echohl WarningMsg
					echom "Double mapping " . "<C-W><C-" . navi_key . "> "
						\ . mapcheck('<C-W><C-' . navi_key . '>', 'n')
						\ . " has been removed."
					call feedkeys("\<CR>")
					echohl None
				endif
			endif
			silent! execute 'nunmap <C-W><C-' . navi_key . '>'
		endif
		if 1 == g:_keys_develop
			echom "Establishing double mapping: " . "<C-W><C-" . navi_key . "> "
			call feedkeys("\<CR>")
		endif
		silent! execute "nnoremap <unique> <silent> <C-W><C-" . navi_key
			\ . "> :call keys#tmux_move('" . a:direction . "', g:navigate)<cr>"

		let s:map_arg_result['<C-W><C-' . navi_key . '>']	=
			\ maparg('<C-W><C-' . navi_key . '>', 'n', 'false')
		if s:map_arg_result['<C-W><C-' . navi_key . '>'] !~?
			\ "tmux_move('" . a:direction . "', g:navigate)"
			echohl WarningMsg
			echom "Error occurred on " . "mapcheck('<C-" . navi_key . ">', 'n')"
			call feedkeys("\<CR>")
			echohl None
		endif
	endif

	if 1 == g:_keys_develop
		echom "mapcheck('<C-W><C-" . navi_key . ">', 'n')		 "
			\ . mapcheck('<C-W><C-' . navi_key . '>', 'n')
		echom "maparg('<C-W><C-" . navi_key . ">', 'n', 'false') "
			\ . maparg('<C-W><C-' . navi_key . '>', 'n', 'false')
		echom "s:map_arg_result['<C-W><C-" . navi_key . ">'] "
			\ . s:map_arg_result['<C-W><C-' . navi_key . '>']
		echom "a:navigate['" . a:direction . "']				 "
			\ . a:navigate[a:direction]
		call feedkeys("\<CR>")
	endif

	if 1 == g:_keys_develop
		echom "\n\r"
		call feedkeys("\<CR>")
		silent! execute '!printf "\n\n"' | redraw!
	endif

endfunction

" Write buffer will enable navigation keys work again while sometimes it was in a buggy trap of vim-tmux-navigator
" User defined key maps
function! s:reload()
	" packadd keys
	" Don't do this manually before all plugins loaded, keys.vim will not notice vim-tmux-navigator
	" correctly -- even you put it after vim-tmux-navigator

	if exists('g:loaded_keys')
		unlet g:loaded_keys
	endif
	" let g:debug_keys	  = 1
	" let keys_load_path  = g:plugin_dir['vim'] . '/after/plugin/keys.vim'
	" let keys_load_path  = g:plugin_dir['vim'] . '/pack/packager/start/keys/after/keys.vim'
	silent! execute "source " . expand('%')
	silent! execute "runtime! " . expand('%')
endfunction

command! -nargs=0 KR :call s:reload()

if exists("g:loaded_tmux_navigator") && exists('$TMUX')
	let g:navigate[s:up]	   = ':TmuxNavigateUp'
	let g:navigate[s:down]	   = ':TmuxNavigateDown'
	let g:navigate[s:left]	   = ':TmuxNavigateLeft'
	let g:navigate[s:right]    = ':TmuxNavigateRight'
	let g:navigate[s:previous] = ':TmuxNavigatePrevious'
else
	let g:navigate[s:up]	   = ':<Nop>'
	let g:navigate[s:down]	   = ':<Nop>'
	let g:navigate[s:left]	   = ':<Nop>'
	let g:navigate[s:right]    = ':<Nop>'
	let g:navigate[s:previous] = ':<Nop>'
endif

call keys#map_key_ad_hoc(s:up,		 g:navigate)
call keys#map_key_ad_hoc(s:down,	 g:navigate)
call keys#map_key_ad_hoc(s:left,	 g:navigate)
call keys#map_key_ad_hoc(s:right,	 g:navigate)
call keys#map_key_ad_hoc(s:previous, g:navigate)

function! s:focus(value)
	let w:focus_lost = a:value
endfunction

augroup focus_changed
	autocmd!
	autocmd FocusLost * call s:focus(1)
	autocmd FocusGained,WinEnter * call s:focus(0)
augroup END

" au! VimEnter * call keys#map_key_ad_hoc('k') | call keys#map_key_ad_hoc('j') | call keys#map_key_ad_hoc('h') | call keys#map_key_ad_hoc('l')

" How to use hasmapto
" if 1 == hasmapto(":call keys#tmux_move('l', g:navigate)<CR>", 'n')
" endif
