```
:::text

keys.vim

This plugin provides the following mappings which allow you to move between
Vim windows seamlessly.

- `<ctrl-h>` => Left
- `<ctrl-j>` => Down
- `<ctrl-k>` => Up
- `<ctrl-l>` => Right
- `<ctrl-\>` => Previous split

It is designed as an extension of
[Vim Tmux Navigator](https://github.com/christoomey/vim-tmux-navigator)
-- mappings allowing you to move between Vim panes and tmux splits seamlessly.
Certainly keys.vim works well and independently in the environment without
Tmux and Vim Tmux Navigator.

===============================================================================
===============================================================================

1. Installation
1.1 Windows navigation key maps
2. Configurables
2.1 Variables
3. Tricks
3.1 Status Line Indicator
4. Compatibility
5. Development
6. References


1. Installation
===============================================================================
The plugin is only one file. So you can check out the repository[1] and drop
keys.vim into your directory:
~/.vim/after/plugin/
for Vim, or
~/.local/share/nvim/site/after/plugin/
for Neovim.
Or, just install it as a normal plugin by using your package manager.

1.1 Windows navigation key maps
=======================================
The plugin provides default key maps for windows navigation. You could remap
them by yourself from changing the global variables' value like this:
let g:alternative         = {}
g:alternative['up']       = 'Up'
g:alternative['down']     = 'Down'
g:alternative['left']     = 'Left'
g:alternative['right']    = 'Right'
g:alternative['previous'] = 'BS'

2. Configurables
===============================================================================

2.1 Variables
=======================================
There are some variables that can be set to change the behavior of the plugin.

g:debug                    Sets the debug switch on(1) and off(0).

g:keys_loaded              Sets the lock of the plugin.

g:loaded_tmux_navigator    Copied from Vim Tmux Navigator

3. Tricks
===============================================================================

3.1 Status Line Indicator
=======================================
Status line indicator for when the navigation was triggered.

"Cursor moved left/right/up/down ..." indecates the status of the navigation

4. Compatibility
===============================================================================
keys.vim uses some shell-isms. Therefore it probably only works on *nix
machines that have a proper shell. It likely also functions under cygwin.


5. Development
===============================================================================
Pull requests are very welcome.

Some updates, with the goal of minimizing interaction and configuration.
Basic functionality out of the box.

6. References
===============================================================================
[1] https://github.com/christoomey/vim-tmux-navigator
[2] https://gist.github.com/mislav/5189704

```
