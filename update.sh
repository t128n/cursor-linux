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

# Function to get latest download URL
get_latest_url() {
    # Define the API endpoint
    local api_endpoint="https://www.cursor.com/api/download?platform=linux-x64&releaseTrack=stable"

    # Fetch the JSON response and extract the downloadUrl
    local download_url=$(curl -s "$api_endpoint" | grep -o '"downloadUrl":"[^"]*' | cut -d'"' -f4)

    # Return the download URL
    echo "$download_url"
}

# Function to handle script cleanup
cleanup() {
    local exit_code=$?
    if [ $exit_code -ne 0 ]; then
        print_error "Update failed with exit code $exit_code"
    fi
    # Remove temporary directory if it exists
    if [ -n "$TEMP_DIR" ] && [ -d "$TEMP_DIR" ]; then
        rm -rf "$TEMP_DIR"
    fi
    exit $exit_code
}

# Set up trap for cleanup
trap cleanup EXIT

# Main update function
main() {
    # Print welcome message
    echo -e "\n${BLUE}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}              ${GREEN}Cursor Update Script${NC}                        ${BLUE}║${NC}"
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

    # Get current version
    if [ ! -f "/opt/cursor/version.txt" ]; then
        print_error "Could not find version file"
        exit 1
    fi
    CURRENT_VERSION=$(cat /opt/cursor/version.txt)

    # Get latest version from download URL
    print_status "Checking for updates..."
    DOWNLOAD_URL=$(get_latest_url)
    if [ $? -ne 0 ]; then
        print_error "Failed to get download URL"
        exit 1
    fi

    # Extract version from download URL
    LATEST_VERSION=$(echo "$DOWNLOAD_URL" | grep -o 'Cursor-[0-9.]*-x86_64' | cut -d'-' -f2)

    # Compare versions
    if [ "$CURRENT_VERSION" = "$LATEST_VERSION" ]; then
        print_success "Cursor is already up to date (version $CURRENT_VERSION)"
        exit 0
    fi

    print_status "Current version: $CURRENT_VERSION"
    print_status "Latest version: $LATEST_VERSION"

    # Ask for confirmation
    print_warning "A new version of Cursor is available"
    read -p "Do you want to update Cursor? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_status "Update cancelled"
        exit 0
    fi

    # Create temporary directory
    print_status "Creating temporary directory..."
    TEMP_DIR=$(mktemp -d)

    # Download the new AppImage
    print_status "Downloading new version..."
    curl -L --progress-bar "$DOWNLOAD_URL" -o "$TEMP_DIR/cursor.AppImage"
    if [ $? -ne 0 ]; then
        print_error "Failed to download new version"
        exit 1
    fi

    # Download the icon
    print_status "Downloading icon..."
    curl -L --progress-bar "https://www.cursor.com/apple-touch-icon.png" -o "$TEMP_DIR/cursor.png"
    if [ $? -ne 0 ]; then
        print_error "Failed to download icon"
        exit 1
    fi

    # Stop any running instances of Cursor
    print_status "Stopping running instances..."
    pkill -f "cursor.AppImage" || true

    # Move the new files to /opt/cursor
    print_status "Installing new version..."
    mv "$TEMP_DIR/cursor.AppImage" /opt/cursor/
    mv "$TEMP_DIR/cursor.png" /opt/cursor/

    # Make the AppImage executable
    print_status "Setting up permissions..."
    chmod +x /opt/cursor/cursor.AppImage

    # Update version file
    echo "$LATEST_VERSION" > /opt/cursor/version.txt

    # Print success message
    echo -e "\n${GREEN}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║${NC}              ${GREEN}Update Complete!${NC}                        ${GREEN}║${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════════════════════════╝${NC}\n"

    print_success "Cursor has been successfully updated to version $LATEST_VERSION!"
}

# Execute main function
main "$@"
