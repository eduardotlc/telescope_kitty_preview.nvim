# Telescope-du-preview.nvim

**Kitty PDF, PNG, SVG and other formats preview in FZF and telescope.**


[![mitbadge]][license] &nbsp;&nbsp;&nbsp; [![Updated - April 2024][updatebadge]](https://)

[mitbadge]: https://img.shields.io/badge/License-MIT-2a7a61?style=for-the-badge
[license]: https://opensource.org/licenses/MIT
[updatebadge]: https://img.shields.io/badge/Updated-April_2024-4a4da0?style=for-the-badge


<eduardotcampos@usp.br> **[2024]**

*Current under developement, still not working, do not install this Plugin*

*If interested in this plugin, star it to follow future updates, until it is properly functioning*


Renders preview through [icat](https://github.com/atextor/icat), imagemagick, [pdftoppm](https://poppler.freedesktop.org/) and pygmentize.

Currently, being primary developed on neovim/telescope and kitty terminal. Despite that, other terminal emulators are schemed for future support,
like iterm and gnome-terminal, though their support is not this project main focus.

If you desire contributing for this other terminals support, or any other code improve, fell free to submit a pull request, your help
will be highly appreciated.


1. [Requirements](#requirements)

    1.1 [Fedora](#fedora-linux)

    1.2 [Debian and Ubuntu](#debian-and-ubuntu-linux)

    1.3 [Plugins](#plugins)
        
      1.3.1 [Markdown utils](#markdown-utils)

2. [Installation](#installation)

3. [Setup](#setup)

4. [Configuration](#configuration)

5. [Features](#features)

6. [Credits](#credits)

7. [TODO](#todo)


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

#### Markdown utils

To use the FZF markdown utils and funtions, it is required:

```neovim
Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app && yarn install' }
```

```bash
npm install -g npx
```

## Installation

[Vim-plug](https://github.com/junegunn/vim-plug)

Add to your init.vim

```vim
Plug 'eduardotlc/telescope-du-preview.nvim'
```

## Setup

**(Obrigatory)**

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

## Configuration

- Configuration folder and files are created during the exec of install.sh

- 

## Features

|  **Preview**     | Kitty | Telescope Neovim | Gnome-terminal | iterm |
| :-----------:    |:-----:|:----------------:|:--------------:|:-----:|
| **SVG**          |   ✅  |        ✕         |        ✕       |   ✕   |
| **PNG**          |   ✅  |        ✕         |        ✕       |   ✕   |
| **PDF**          |   ✅  |        ✕         |        ✕       |   ✕   |
| **Text Files**   |   ✅  |        ✕         |        ✕       |   ✕   |
| **Todo.txt** |   ✕   |        ✕         |        ✕       |   ✕   |
| **epub**         |   ✕   |        ✕         |        ✕       |   ✕   |
| **Bib Managing** |   ✕   |        ✕         |        ✕       |   ✕   |
| **Zotero Cites** |   ✕   |        ✕         |        ✕       |   ✕   |

### Environment Variables

- KITTY_TELESCOPE_BOOKMARKS

Bookmarks storing file path, defaults to ~/.kitty_bookmarks,
needs to be formatted like:

```bash
Name: /file/base/path
Downloads: ~/Downloads
Desktop: /usr/local/share/applications
```


## Credits

based on [telescope-media-preview](https://github.com/nvim-telescope/telescope-media-files.nvim)


## TODO

- [ ] Implement sioyek PDF open

- [ ] Implement Zotero browser

- [ ] Implement bibtex browser

- [ ] Neovim checkhealth

- [ ] Terminal and nvim fzf dictionary consulting and spell checking

- [ ] Bibtex managing and citing

- [ ] Zotero citing
