#!/usr/bin/env bash

# -TODO:Check necessity of adding the source of widgets line in .rc from shell

set -o nounset    # error when referencing undefined variable
set -o errexit    # exit when command fails

BASEDIR=$(dirname "$0")

# Check and creates config file

if [ -z ${XDG_CONFIG_HOME} ]; then
    DUFZF_CONFIG_DIR="${XDG_CONFIG_HOME}/kitty_telescope_preview"
elif [ -d "${HOME}/.config" ]; then
    DUFZF_CONFIG_DIR="${HOME}/.config/kitty_telescope_preview"
else
    DUFZF_CONFIG_DIR="${HOME}/.kitty_telescope_preview"
fi

echo -e "\nConfig folder set to \e[1;36m ${DUFZF_CONFIG_DIR} \e[0m\n"
mkdir -p "${DUFZF_CONFIG_DIR}"

if [ -f "${DUFZF_CONFIG_DIR}/kitty_telescope_preview.config" ]; then
    echo -e "Config file already exists at \e[1;36m ${DUFZF_CONFIG_DIR}/kitty_telescope_preview.config \e[0m\n"
fi

cp -p "${BASEDIR}/kitty_telescope_preview.config" "${DUFZF_CONFIG_DIR}"

# Getting installation directory
if [[ ":$PATH:" == *":${HOME}/bin:"* ]]; then
  DUFZF_INSTALL_DIR="${HOME}/bin"
elif [[ ":$PATH:" == *":${HOME}/.local/bin:"* ]]; then
  DUFZF_INSTALL_DIR="${HOME}/.local/bin"
else
  DUFZF_INSTALL_DIR="/usr/local/bin"
fi

if [ -f "${DUFZF_INSTALL_DIR}/kitty_telescope_preview.config" ]; then
    echo -e "Config file already exists at \e[1;36m ${DUFZF_CONFIG_DIR}/kitty_telescope_preview.config \e[0m\n"
fi
echo -e "Installing to \e[1;36m ${DUFZF_INSTALL_DIR} \e[0m\n"

cp -p -u "${BASEDIR}/scripts/kitty_telescope_widgets.sh" "${BASEDIR}/scripts/kitty_telescope_preview.sh" "${DUFZF_INSTALL_DIR}"
