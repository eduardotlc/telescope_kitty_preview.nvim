# Telescope-du-preview.nvim

**Kitty PDF, PNG, SVG and other formats preview in FZF and telescope.**

|        License           |    Update       |
| :----------------------: | :-------------: |
|  [![mitbadge]][license]  |  ![lastupdate]  |

[mitbadge]: ./images/badge_mit.svg
[lastupdate]: ./images/badge_update.svg
[license]: https://opensource.org/licenses/MIT

<eduardotcampos@usp.br> **[2024]**

*Current under developement, still not working, do not install this Plugin*

*If interested in this plugin, star it to follow future updates, until it is properly functioning*


Renders preview through [icat](https://github.com/atextor/icat), imagemagick, [pdftoppm](https://poppler.freedesktop.org/) and pygmentize.

Currently, being primary developed on neovim/telescope and kitty terminal. Despite that, other terminal emulators are schemed for future support,
like iterm and gnome-terminal, though their support is not this project main focus.

If you desire contributing for this other terminals support, or any other code improvement, fell free to submit a pull request, your help
will be highly appreciated.

## Requirements

- [kitty](https://github.com/kovidgoyal/kitty)

- [fzf](https://github.com/junegunn/fzf)

- [poppler](https://poppler.freedesktop.org/)

- [icat](https://github.com/atextor/icat)

- [ImageMagick](https://github.com/ImageMagick/ImageMagick)

- [Pygmentize](https://github.com/dedalozzo/pygmentize)

### Fedora Linux

```bash
sudo dnf install fzf gawk kitty poppler
```

### Debian and Ubuntu Linux

```bash
sudo apt install fzf gawk kitty libpoppler-dev
```

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

## Features

|  **Preview**   | Kitty | Telescope Neovim | Gnome-terminal | iterm |
| :-----------:  |:-----:|:----------------:|:--------------:|:-----:|
| **SVG**        |   ✅  |        ✕         |        ✕       |   ✕   |
| **PNG**        |   ✅  |        ✕         |        ✕       |   ✕   |
| **PDF**        |   ✅  |        ✕         |        ✕       |   ✕   |
| **text files** |   ✅  |        ✕         |        ✕       |   ✕   |
| **epub**       |   ✕   |        ✕         |        ✕       |   ✕   |


## Credits

based on [telescope-media-preview](https://github.com/nvim-telescope/telescope-media-files.nvim)


## TODO

- [ ]  Implement sioyek PDF open

- [ ] Implement Zotero browser

- [ ] Implement bibtex browser

- [ ] Neovim checkhealth
