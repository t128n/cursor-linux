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
        print_error "Installation failed with exit code $exit_code"
    fi
    # Remove temporary directory if it exists
    if [ -n "$TEMP_DIR" ] && [ -d "$TEMP_DIR" ]; then
        rm -rf "$TEMP_DIR"
    fi
    exit $exit_code
}

# Set up trap for cleanup
trap cleanup EXIT

# Main installation function
main() {
    # Print welcome message
    echo -e "\n${BLUE}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}              ${GREEN}Cursor Installation Script${NC}                  ${BLUE}║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════════════════════╝${NC}\n"

    # Check if running as root
    if [ "$EUID" -ne 0 ]; then
        print_error "Please run as root (use sudo)"
        exit 1
    fi

    # Check if cursor is installed in /opt/cursor
    if [ -d "/opt/cursor" ]; then
        print_warning "Cursor is already installed"
        read -p "Do you want to overwrite it? (y/N) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_status "Installation cancelled"
            exit 0
        fi
    fi

    # Create temporary directory
    print_status "Creating temporary directory..."
    TEMP_DIR=$(mktemp -d)

    # Get download URL
    print_status "Getting download URL..."
    DOWNLOAD_URL=$(get_latest_url)
    if [ $? -ne 0 ]; then
        print_error "Failed to get download URL"
        exit 1
    fi

    # Download the AppImage
    print_status "Downloading Cursor..."
    curl -L --progress-bar "$DOWNLOAD_URL" -o "$TEMP_DIR/cursor.AppImage"
    if [ $? -ne 0 ]; then
        print_error "Failed to download Cursor"
        exit 1
    fi

    # Download the icon
    print_status "Downloading Cursor icon..."
    curl -L --progress-bar "https://www.cursor.com/apple-touch-icon.png" -o "$TEMP_DIR/cursor.png"
    if [ $? -ne 0 ]; then
        print_error "Failed to download icon"
        exit 1
    fi

    # Create /opt/cursor directory
    print_status "Creating installation directory..."
    mkdir -p /opt/cursor

    # Move the AppImage and icon to /opt/cursor
    print_status "Installing files..."
    mv "$TEMP_DIR/cursor.AppImage" /opt/cursor/
    mv "$TEMP_DIR/cursor.png" /opt/cursor/

    # Make the AppImage executable
    print_status "Setting up permissions..."
    chmod +x /opt/cursor/cursor.AppImage

    # Create symlink in /usr/local/bin
    print_status "Creating command-line symlink..."
    ln -sf /opt/cursor/cursor.AppImage /usr/local/bin/cursor

    # Create desktop entry
    print_status "Creating desktop entry..."
    cat > /usr/share/applications/cursor.desktop << EOL
[Desktop Entry]
Name=Cursor
Comment=AI-first code editor
Exec=/opt/cursor/cursor.AppImage
Icon=/opt/cursor/cursor.png
Terminal=false
Type=Application
Categories=Development;TextEditor;IDE;
StartupWMClass=Cursor
EOL

    # Extract version from download URL and create version.txt
    VERSION=$(echo "$DOWNLOAD_URL" | grep -o 'Cursor-[0-9.]*-x86_64' | cut -d'-' -f2)
    echo "$VERSION" > /opt/cursor/version.txt

    # Print success message
    echo -e "\n${GREEN}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║${NC}              ${GREEN}Installation Complete!${NC}                      ${GREEN}║${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════════════════════════╝${NC}\n"

    print_success "Cursor has been successfully installed!"
    print_status "Version: $VERSION"
    print_status "You can now launch Cursor from your applications menu or by typing 'cursor' in your terminal"
}

# Execute main function
main "$@"