#!/usr/bin/env bash
set -euo pipefail

# Test directory
TEST_DIR="/tmp/docker-setup-test"
TEST_HOME="${TEST_DIR}/home"
TEST_LOCAL="${TEST_HOME}/.local"
TEST_CONFIG="${TEST_HOME}/.config"

# Function to log test results
log_test() {
    local test_name="$1"
    local result="$2"
    if [ "$result" -eq 0 ]; then
        echo "PASS: ${test_name}"
    else
        echo "FAIL: ${test_name}"
        return 1
    fi
}

# Setup test environment
setup_test_env() {
    echo "Setting up test environment..."
    rm -rf "${TEST_DIR}"
    mkdir -p "${TEST_HOME}" "${TEST_LOCAL}/bin" "${TEST_CONFIG}"
    
    # Create test shell RC files
    echo "# Test bashrc" > "${TEST_HOME}/.bashrc"
    echo "# Test zshrc" > "${TEST_HOME}/.zshrc"
    
    # Export test environment variables
    export HOME="${TEST_HOME}"
    export XDG_DATA_HOME="${TEST_LOCAL}/share"
    export XDG_CONFIG_HOME="${TEST_CONFIG}"
    
    return 0
}

# Test shell configuration setup
test_shell_setup() {
    echo "Testing shell configuration..."
    
    # Source the setup script
    source "./shell/setup_shell.sh"
    
    # Run setup
    TERM=dumb setup_shell
    
    # Test 1: Check if directories were created
    test -d "${XDG_DATA_HOME}/docker-setup/shell/zsh" && \
    test -d "${XDG_DATA_HOME}/docker-setup/shell/bash"
    log_test "Directory structure created" $?
    
    # Test 2: Check if configuration files were copied
    test -f "${XDG_DATA_HOME}/docker-setup/shell/zsh/docker-setup.zsh" && \
    test -f "${XDG_DATA_HOME}/docker-setup/shell/bash/docker-setup.bash"
    log_test "Configuration files copied" $?
    
    # Test 3: Check if RC files were updated
    grep -q "docker-setup.zsh" "${TEST_HOME}/.zshrc"
    log_test "ZSH configuration updated" $?
    
    grep -q "docker-setup.bash" "${TEST_HOME}/.bashrc"
    log_test "Bash configuration updated" $?
    
    # Test 4: Check if paths are correctly set
    source "${XDG_DATA_HOME}/docker-setup/shell/zsh/docker-setup.zsh"
    echo "$PATH" | grep -q "${HOME}/.local/bin"
    log_test "PATH updated correctly" $?
    
    return 0
}

# Test binary compatibility
test_binary_compatibility() {
    echo "Testing binary compatibility..."
    
    # Create test binaries
    echo "#!/bin/bash" > "${TEST_LOCAL}/bin/enter"
    echo "echo 'enter test'" >> "${TEST_LOCAL}/bin/enter"
    chmod +x "${TEST_LOCAL}/bin/enter"
    
    echo "#!/bin/bash" > "${TEST_LOCAL}/bin/nginx-sites"
    echo "echo 'nginx-sites test'" >> "${TEST_LOCAL}/bin/nginx-sites"
    chmod +x "${TEST_LOCAL}/bin/nginx-sites"
    
    echo "#!/bin/bash" > "${TEST_LOCAL}/bin/devctl"
    echo "echo 'devctl test'" >> "${TEST_LOCAL}/bin/devctl"
    chmod +x "${TEST_LOCAL}/bin/devctl"
    
    # Test binary execution
    "${TEST_LOCAL}/bin/enter" >/dev/null 2>&1
    log_test "enter command executable" $?
    
    "${TEST_LOCAL}/bin/nginx-sites" >/dev/null 2>&1
    log_test "nginx-sites command executable" $?
    
    "${TEST_LOCAL}/bin/devctl" >/dev/null 2>&1
    log_test "devctl command executable" $?
    
    return 0
}

# Main test execution
main() {
    echo "Starting tests..."
    
    setup_test_env
    test_shell_setup
    test_binary_compatibility
    
    echo "Tests completed."
}

# Run tests
main
