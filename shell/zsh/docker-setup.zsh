# Docker Setup ZSH Configuration
# This file is automatically sourced by the installation script

# Set up XDG base directories if not already defined
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"

# Docker Setup specific paths
export DOCKER_SETUP_HOME="${XDG_DATA_HOME}/docker-setup"
export DOCKER_SETUP_BIN="${HOME}/.local/bin"
export DOCKER_SETUP_CONF="${XDG_CONFIG_HOME}/docker-setup"

# Add docker-setup binaries to PATH if not already present
if [[ ":$PATH:" != *":${DOCKER_SETUP_BIN}:"* ]]; then
    export PATH="${DOCKER_SETUP_BIN}:${PATH}"
fi

# Define aliases for docker-setup commands
alias enter="${DOCKER_SETUP_BIN}/enter"
alias nginx-sites="${DOCKER_SETUP_BIN}/nginx-sites"
alias devctl="${DOCKER_SETUP_BIN}/devctl"

# Load docker-setup completions if they exist
if [[ -f "${DOCKER_SETUP_HOME}/shell/zsh/completions.zsh" ]]; then
    source "${DOCKER_SETUP_HOME}/shell/zsh/completions.zsh"
fi
