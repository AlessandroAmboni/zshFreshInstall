#!/bin/bash
set -e

# This script installs zsh, Oh My Zsh, and selected plugins for the current user on Debian 12.

PLUGINS=(git fzf z fzf-tab zsh-autosuggestions zsh-syntax-highlighting fast-syntax-highlighting)

# Ensure HOME is correct for the current user
if [ "$HOME" != "/home/$(whoami)" ]; then
    echo "Warning: HOME ($HOME) does not match current user directory (/home/$(whoami))"
    export HOME="/home/$(whoami)"
    echo "HOME has been set to $HOME"
fi

# Ensure not running as root
if [ "$(id -u)" -eq 0 ]; then
    echo "Please run this script as your normal user, not root."
    exit 1
fi

# Install system dependencies
sudo apt-get update
sudo apt-get install -y zsh git curl fzf

# Install Oh My Zsh for the current user
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Installing Oh My Zsh..."
    export RUNZSH=no
    export CHSH=no
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
    echo "Oh My Zsh already installed for user $USER."
fi

ZSH_CUSTOM=${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}

# Install external plugins for the current user
declare -A EXTERNAL_PLUGINS
EXTERNAL_PLUGINS=(
    [fzf-tab]="https://github.com/Aloxaf/fzf-tab"
    [zsh-autosuggestions]="https://github.com/zsh-users/zsh-autosuggestions"
    [zsh-syntax-highlighting]="https://github.com/zsh-users/zsh-syntax-highlighting"
    [fast-syntax-highlighting]="https://github.com/zdharma-continuum/fast-syntax-highlighting"
)

for plugin in "${PLUGINS[@]}"; do
    if [[ ${EXTERNAL_PLUGINS[$plugin]+_} ]]; then
        PLUGIN_DIR="$ZSH_CUSTOM/plugins/$plugin"
        if [ ! -d "$PLUGIN_DIR" ]; then
            git clone --depth=1 "${EXTERNAL_PLUGINS[$plugin]}" "$PLUGIN_DIR"
        fi
    fi
done

# Install z (z jump-around) for the current user if not present
if [ ! -d "$ZSH_CUSTOM/plugins/z" ]; then
    git clone --depth=1 https://github.com/rupa/z "$ZSH_CUSTOM/plugins/z"
fi

# Add or update plugins line in .zshrc for the current user
ZSHRC="$HOME/.zshrc"
if ! grep -q "^plugins=(" "$ZSHRC"; then
    echo "plugins=(${PLUGINS[*]})" >> "$ZSHRC"
else
    sed -i.bak "/^plugins=/c\plugins=(${PLUGINS[*]})" "$ZSHRC"
fi

echo "Installation complete for user $USER! Start a new zsh session or run 'zsh' to use your new setup."
