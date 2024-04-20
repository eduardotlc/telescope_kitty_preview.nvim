#!/usr/bin/env bash

# -TODO:Check necessity of adding the source of widgets line in .rc from shell

set -o nounset    # error when referencing undefined variable
set -o errexit    # exit when command fails
if [ "${SHELL}" == *"*zsh" ]; then
  SHELL_CONFIG_RC=$HOME/.zshrc
elif [ "${SHELL}" == *"*bash" ]; then
  SHELL_CONFIG_RC=$HOME/.bashrc
fi

BASEDIR=$(dirname "$0")

# Check and creates config file

if [ -z ${XDG_CONFIG_HOME} ]; then
    KITTY_TELESCOPE_CONFIG_DIR="${XDG_CONFIG_HOME}/kitty_telescope_preview"
elif [ -d "${HOME}/.config" ]; then
    KITTY_TELESCOPE_CONFIG_DIR="${HOME}/.config/kitty_telescope_preview"
else
    KITTY_TELESCOPE_CONFIG_DIR="${HOME}/.kitty_telescope_preview"
fi

echo -e "\nConfig folder set to \e[1;36m ${KITTY_TELESCOPE_CONFIG_DIR} \e[0m\n"
mkdir -p "${KITTY_TELESCOPE_CONFIG_DIR}"

if [ -f "${KITTY_TELESCOPE_CONFIG_DIR}/kitty_telescope_preview.config" ]; then
    echo -e "Config file already exists at \e[1;36m ${KITTY_TELESCOPE_CONFIG_DIR}/kitty_telescope_preview.config \e[0m\n"
fi

cp -p "${BASEDIR}/kitty_telescope_preview.config" "${KITTY_TELESCOPE_CONFIG_DIR}"

# Getting installation directory
if [[ ":$PATH:" == *":${HOME}/bin:"* ]]; then
  KITTY_TELESCOPE_INSTALL_DIR="${HOME}/bin"
elif [[ ":$PATH:" == *":${HOME}/.local/bin:"* ]]; then
  KITTY_TELESCOPE_INSTALL_DIR="${HOME}/.local/bin"
else
  KITTY_TELESCOPE_INSTALL_DIR="/usr/local/bin"
fi

if [ -f "${KITTY_TELESCOPE_INSTALL_DIR}/kitty_telescope_preview.config" ]; then
    echo -e "Config file already exists at \e[1;36m ${KITTY_TELESCOPE_CONFIG_DIR}/kitty_telescope_preview.config \e[0m\n"
fi
echo -e "Installing to \e[1;36m ${KITTY_TELESCOPE_INSTALL_DIR} \e[0m\n"

cp -p -u "${BASEDIR}/scripts/kitty_telescope_widgets.sh" "${BASEDIR}/scripts/kitty_telescope_preview.sh" "${KITTY_TELESCOPE_INSTALL_DIR}"

echo -e "\e[1;33mConfig personal important settings?\e[0m? [y/N]"
read answer
if [[ $answer =~ ^[Yy]$ ]]; then
# If the user responds with 'y' or 'Y', delete the directory
  if [[ ! -z $KITTY_TELESCOPE_BOOKMARKS ]]; then
    echo -e "Bookmark file to store bookmarks path: \e[0;30mDefault: ${KITTY_TELESCOPE_CONFIG_DIR}/kitty_telescope_bookmarks\e[0m"
    read answer
    if [[ -z $answer ]]; then
      KITTY_TELESCOPE_BOOKMARKS="${answer}"
    else
      KITTY_TELESCOPE_BOOKMARKS="${HOME}/.kitty_telescope_bookmarks"
    fi
    echo "export KITTY_TELESCOPE_BOOKMARKS=${KITTY_TELESCOPE_BOOKMARKS}" >> "${SHELL_CONFIG_RC}"
    echo "added Bookmark variable to .zshrc"
  fi
  if [[ ! -z $KITTY_TELESCOPE_CONFIG_FILE ]]; then
    echo -e "Bookmark file to store bookmarks path: \e[0;30mDefault: ${KITTY_TELESCOPE_CONFIG_DIR}/KITTY_TELESCOPE_CONFIG_FILE\e[0m"
    read answer
    if $answer; then
      KITTY_TELESCOPE_CONFIG_FILE="${answer}"
    else
      KITTY_TELESCOPE_CONFIG_FILE="${KITTY_TELESCOPE_CONFIG_DIR}/KITTY_TELESCOPE_CONFIG_FILE"
    fi
    echo "export KITTY_TELESCOPE_CONFIG_FILE=${KITTY_TELESCOPE_CONFIG_FILE}" >> "${SHELL_CONFIG_RC}"
    echo "added Bookmark variable to .zshrc"
  fi

    sed -i "s|^background_image[[:space:]]\+.*$|background_image    $SELECTED_IMAGE|" "${KITTY_CONF}"
    # if [[ ! -z $KITTY_TELESCOPE_NOTES ]]; then
    if [[ ! -z $KITTY_TELESCOPE_THEMES_EXCLUDE ]]; then
      echo -e "\e[1;31m Deleted $dir \e[0m \n"
      depth_change=true
    else
      echo -e "\e[1;36m Skipped $dir \e[0m \n"
    fi
fi

  # If any directories were deleted, check again for new empty directories
if [[ "${depth_change}" =~ true ]]; then
  delete_empty_dirs
fi

