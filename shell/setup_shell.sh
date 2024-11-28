#!/usr/bin/env bash

# Function to set up shell configuration for docker-setup
setup_shell() {
    local is_interactive=0
    if [ -t 0 ]; then
        is_interactive=1
    fi

    # Create necessary directories
    mkdir -p "${XDG_DATA_HOME:-$HOME/.local/share}/docker-setup"
    mkdir -p "${XDG_CONFIG_HOME:-$HOME/.config}/docker-setup"
    mkdir -p "$HOME/.local/bin"

    # Detect and configure shells
    local shell_config_added=0

    # Configure ZSH if present
    if [ -f "$HOME/.zshrc" ]; then
        # Create zsh config directory if it doesn't exist
        mkdir -p "${XDG_DATA_HOME:-$HOME/.local/share}/docker-setup/shell/zsh"
        
        # Copy zsh configuration
        cp "shell/zsh/docker-setup.zsh" "${XDG_DATA_HOME:-$HOME/.local/share}/docker-setup/shell/zsh/"
        
        # Add source line to .zshrc if not present
        local zsh_source_line="source \"${XDG_DATA_HOME:-$HOME/.local/share}/docker-setup/shell/zsh/docker-setup.zsh\""
        if ! grep -q "docker-setup.zsh" "$HOME/.zshrc"; then
            echo "$zsh_source_line" >> "$HOME/.zshrc"
            shell_config_added=1
        fi
    fi

    # Configure Bash if present
    if [ -f "$HOME/.bashrc" ]; then
        # Create bash config directory if it doesn't exist
        mkdir -p "${XDG_DATA_HOME:-$HOME/.local/share}/docker-setup/shell/bash"
        
        # Copy bash configuration
        cp "shell/bash/docker-setup.bash" "${XDG_DATA_HOME:-$HOME/.local/share}/docker-setup/shell/bash/"
        
        # Add source line to .bashrc if not present
        local bash_source_line="source \"${XDG_DATA_HOME:-$HOME/.local/share}/docker-setup/shell/bash/docker-setup.bash\""
        if ! grep -q "docker-setup.bash" "$HOME/.bashrc"; then
            echo "$bash_source_line" >> "$HOME/.bashrc"
            shell_config_added=1
        fi
    fi

    # Notify user if shell configuration was added and we're in interactive mode
    if [ $shell_config_added -eq 1 ] && [ $is_interactive -eq 1 ]; then
        if command -v dialog >/dev/null 2>&1; then
            dialog --title "Shell Configuration" --msgbox "Shell configuration has been updated.\nPlease restart your shell or source your shell's RC file to apply changes." 8 60
        else
            echo "Shell configuration has been updated."
            echo "Please restart your shell or source your shell's RC file to apply changes."
        fi
    fi
}

# Export the function so it can be used by the main install script
export -f setup_shell
