# Cursor Linux Installation Scripts

This repository contains a set of scripts to manage the installation, update, and uninstallation of Cursor on Linux systems. Cursor is an AI-first code editor that helps you write better code faster.

## Quick Start

You can install Cursor directly using curl:

```bash
curl -sSL https://raw.githubusercontent.com/t128n/cursor-linux/main/install.sh | sudo bash
```

## Scripts Overview

### install.sh
Installs Cursor on your Linux system. The script:
- Downloads the latest Cursor AppImage
- Downloads the Cursor icon
- Installs it to `/opt/cursor`
- Creates necessary symlinks and desktop entries
- Sets up proper permissions

### update.sh
Checks for and installs updates to Cursor. The script:
- Verifies the current installed version
- Checks for newer versions
- Downloads and installs updates if available
- Handles the update process safely

### uninstall.sh
Removes Cursor from your system. The script:
- Removes all installed components
- Cleans up symlinks and desktop entries
- Removes the installation directory

## Quick Commands

Install Cursor:
```bash
curl -sSL https://raw.githubusercontent.com/t128n/cursor-linux/main/install.sh | sudo bash
```

Update Cursor:
```bash
curl -sSL https://raw.githubusercontent.com/t128n/cursor-linux/main/update.sh | sudo bash
```

Uninstall Cursor:
```bash
curl -sSL https://raw.githubusercontent.com/t128n/cursor-linux/main/uninstall.sh | sudo bash
```

## Manual Installation

If you prefer to install manually:

1. Clone this repository:
```bash
git clone https://github.com/t128n/cursor-linux.git
cd cursor-linux
```

2. Make the scripts executable:
```bash
chmod +x install.sh update.sh uninstall.sh
```

3. Run the installation script:
```bash
sudo ./install.sh
```

## Prerequisites

- Linux operating system
- Root/sudo access
- `curl` command-line tool (for direct installation)
- Internet connection

## Installation Location

Cursor is installed to the following locations:
- Main application: `/opt/cursor/cursor.AppImage`
- Icon: `/opt/cursor/cursor.png`
- Version file: `/opt/cursor/version.txt`
- Desktop entry: `/usr/share/applications/cursor.desktop`
- Command-line symlink: `/usr/local/bin/cursor`

## Features

- Automatic version checking
- Safe installation and update procedures
- Clean uninstallation
- Desktop integration
- Command-line access
- Proper system integration
- One-line installation via curl

## Contributing

Feel free to submit issues and enhancement requests!

## License

This project is licensed under the MIT License - see the LICENSE file for details. 