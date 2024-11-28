#!/usr/bin/env bash

# Shell configuration module for docker-setup
# This module handles shell-specific configurations and testing

# Set strict mode
set -euo pipefail

# Default paths following XDG specification
readonly DEFAULT_XDG_DATA_HOME="${HOME}/.local/share"
readonly DEFAULT_XDG_CONFIG_HOME="${HOME}/.config"
readonly DEFAULT_XDG_STATE_HOME="${HOME}/.local/state"
readonly DEFAULT_XDG_CACHE_HOME="${HOME}/.cache"

# Docker setup specific paths
readonly DOCKER_SETUP_HOME="${XDG_DATA_HOME:-$DEFAULT_XDG_DATA_HOME}/docker-setup"
readonly DOCKER_SETUP_BIN="${HOME}/.local/bin"
readonly DOCKER_SETUP_CONF="${XDG_CONFIG_HOME:-$DEFAULT_XDG_CONFIG_HOME}/docker-setup"

# Load docker-setup configuration if it exists
if [ -f "${DOCKER_SETUP_CONF}/docker-setup.config" ]; then
    source "${DOCKER_SETUP_CONF}/docker-setup.config"
else
    # Copy template if it doesn't exist
    mkdir -p "${DOCKER_SETUP_CONF}"
    cp "${DOCKER_SETUP_HOME}/config/docker-setup.config.template" "${DOCKER_SETUP_CONF}/docker-setup.config"
    source "${DOCKER_SETUP_CONF}/docker-setup.config"
fi

# Shell configurations
readonly SHELL_CONFIGS=(
    "zsh:.zshrc:docker-setup.zsh"
    "bash:.bashrc:docker-setup.bash"
)

# Function to log messages with different levels
log_message() {
    local level="$1"
    local message="$2"
    local is_interactive=0
    [ -t 0 ] && is_interactive=1

    if [ "$is_interactive" -eq 1 ] && command -v dialog >/dev/null 2>&1; then
        case "$level" in
            "info")
                dialog --title "Information" --msgbox "$message" 8 60
                ;;
            "error")
                dialog --title "Error" --msgbox "$message" 8 60
                ;;
            *)
                dialog --title "Message" --msgbox "$message" 8 60
                ;;
        esac
    else
        echo "$message"
    fi
}

# Function to verify shell configuration
verify_shell_config() {
    local shell_name="$1"
    local rc_file="$2"
    local config_file="$3"
    local success=0

    # Check if configuration file exists
    if [ ! -f "${DOCKER_SETUP_HOME}/shell/${shell_name}/${config_file}" ]; then
        log_message "error" "Configuration file for ${shell_name} not found"
        return 1
    fi

    # Check if RC file contains our configuration
    if ! grep -q "docker-setup.${shell_name}" "${HOME}/${rc_file}" 2>/dev/null; then
        log_message "error" "Shell configuration not found in ${rc_file}"
        return 1
    fi

    # Verify PATH configuration
    if ! echo "$PATH" | grep -q "${DOCKER_SETUP_BIN}"; then
        log_message "error" "PATH configuration incorrect"
        return 1
    fi

    return 0
}

# Function to configure shell environment
configure_shell() {
    local shell_name="$1"
    local rc_file="$2"
    local config_file="$3"
    local config_dir="${DOCKER_SETUP_HOME}/shell/${shell_name}"
    
    # Create shell configuration directory
    mkdir -p "$config_dir"
    
    # Create shell configuration
    cat > "${config_dir}/${config_file}" << EOF
# Docker Setup ${shell_name} Configuration
# Generated by docker-setup installer

# XDG Base Directory Specification
export XDG_DATA_HOME="\${XDG_DATA_HOME:-$DEFAULT_XDG_DATA_HOME}"
export XDG_CONFIG_HOME="\${XDG_CONFIG_HOME:-$DEFAULT_XDG_CONFIG_HOME}"
export XDG_STATE_HOME="\${XDG_STATE_HOME:-$DEFAULT_XDG_STATE_HOME}"
export XDG_CACHE_HOME="\${XDG_CACHE_HOME:-$DEFAULT_XDG_CACHE_HOME}"

# Docker Setup paths
export DOCKER_SETUP_HOME="\${XDG_DATA_HOME}/docker-setup"
export DOCKER_SETUP_BIN="\${HOME}/.local/bin"
export DOCKER_SETUP_CONF="\${XDG_CONFIG_HOME}/docker-setup"

# Update PATH if needed
if [[ ":\$PATH:" != *":\${DOCKER_SETUP_BIN}:"* ]]; then
    export PATH="\${DOCKER_SETUP_BIN}:\${PATH}"
fi

# Docker Setup aliases
alias enter="\${DOCKER_SETUP_BIN}/enter"
alias nginx-sites="\${DOCKER_SETUP_BIN}/nginx-sites"
alias devctl="\${DOCKER_SETUP_BIN}/devctl"
EOF

    # Add source line to RC file if not present
    local source_line="source \"\${XDG_DATA_HOME:-$DEFAULT_XDG_DATA_HOME}/docker-setup/shell/${shell_name}/${config_file}\""
    if ! grep -q "docker-setup.${shell_name}" "${HOME}/${rc_file}" 2>/dev/null; then
        echo "$source_line" >> "${HOME}/${rc_file}"
    fi
}

# Main shell setup function
setup_shell() {
    local test_mode="${1:-0}"
    local success=1

    # Create necessary directories
    mkdir -p "${DOCKER_SETUP_HOME}" "${DOCKER_SETUP_BIN}" "${DOCKER_SETUP_CONF}"

    # Process each shell configuration
    for config in "${SHELL_CONFIGS[@]}"; do
        IFS=: read -r shell rc_file config_file <<< "$config"
        
        if [ -f "${HOME}/${rc_file}" ]; then
            if [ "$test_mode" -eq 1 ]; then
                verify_shell_config "$shell" "$rc_file" "$config_file" || success=0
            else
                configure_shell "$shell" "$rc_file" "$config_file"
            fi
        fi
    done

    # Verify binary paths
    for cmd in enter nginx-sites devctl; do
        if [ ! -x "${DOCKER_SETUP_BIN}/${cmd}" ] && [ "$test_mode" -eq 1 ]; then
            log_message "error" "Binary ${cmd} not found or not executable"
            success=0
        fi
    done

    return "$((1 - success))"
}

# Export functions
export -f setup_shell
export -f log_message
export -f verify_shell_config
export -f configure_shell
