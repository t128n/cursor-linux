#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print status messages
print_status() {
    echo -e "${BLUE}==>${NC} $1"
}

# Function to print success messages
print_success() {
    echo -e "${GREEN}==>${NC} $1"
}

# Function to print error messages
print_error() {
    echo -e "${RED}==>${NC} $1"
}

# Function to print warning messages
print_warning() {
    echo -e "${YELLOW}==>${NC} $1"
}

# Function to handle script cleanup
cleanup() {
    local exit_code=$?
    if [ $exit_code -ne 0 ]; then
        print_error "Uninstallation failed with exit code $exit_code"
    fi
    exit $exit_code
}

# Set up trap for cleanup
trap cleanup EXIT

# Main uninstallation function
main() {
    # Print welcome message
    echo -e "\n${BLUE}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}              ${RED}Cursor Uninstallation Script${NC}                ${BLUE}║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════════════════════╝${NC}\n"

    # Check if running as root
    if [ "$EUID" -ne 0 ]; then
        print_error "Please run as root (use sudo)"
        exit 1
    fi

    # Check if cursor is installed
    if [ ! -d "/opt/cursor" ]; then
        print_warning "Cursor is not installed"
        exit 0
    fi

    # Ask for confirmation
    print_warning "This will completely remove Cursor from your system"
    read -p "Are you sure you want to uninstall Cursor? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_status "Uninstallation cancelled"
        exit 0
    fi

    # Remove symlink
    if [ -L "/usr/local/bin/cursor" ]; then
        print_status "Removing command-line symlink..."
        rm -f /usr/local/bin/cursor
    fi

    # Remove desktop entry
    if [ -f "/usr/share/applications/cursor.desktop" ]; then
        print_status "Removing desktop entry..."
        rm -f /usr/share/applications/cursor.desktop
    fi

    # Remove Cursor directory and all its contents
    if [ -d "/opt/cursor" ]; then
        print_status "Removing Cursor files..."
        rm -rf /opt/cursor
    fi

    # Print success message
    echo -e "\n${GREEN}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║${NC}              ${GREEN}Uninstallation Complete!${NC}                    ${GREEN}║${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════════════════════════╝${NC}\n"

    print_success "Cursor has been successfully uninstalled!"
}

# Execute main function
main "$@"
