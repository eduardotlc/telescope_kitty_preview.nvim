# Telescope-du-preview.nvim

*Current under developement, still not working, do not install this Plugin*

*If interested in this plugin, star it to see updates, until it is functioning*

Kitty pdf and image preview telescope extension

Renders preview through termpdf and icat

Sioyek pdf viewer open pdf, Zotero local storage browser and bibtex browser

## Requirements

- kitty

- termpdf

- icat

- fzf

- fd

### Plugins

[Vim-plug](https://github.com/junegunn/vim-plug)

Add to your init.vim

```vim
Plug 'nvim-lua/popup.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
```

## Installation

[Vim-plug](https://github.com/junegunn/vim-plug)

Add to your init.vim

```vim
Plug 'eduardotlc/telescope-du-preview.nvim'
```

## Setup (Obrigatory)

On a lua file required by your init.vim:

```lua
require("telescope").setup({
  extensions = {
    du_preview = {},
    },
})

require("telescope").load_extension("du_preview")
```

For example, if you add the above code to a config.lua file, on your
~/.config/nvim/ folder, add the following to your init.vim:

```vim
lua require("config")
```

## Credits

based on [telescope-media-preview](https://github.com/nvim-telescope/telescope-media-files.nvim)


## TODO

- Implement sioyek pdf open

- Implement Zotero browser

- Implement bibtex browser
