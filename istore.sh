#!/bin/sh
#
# iStore OpenWrt Installation Script
# Author: Your Name
# Repository: https://github.com/yourusername/istore-installer
#
# Description: Automated installation of iStore on OpenWrt systems
# Version: 1.0.0
# License: MIT

set -euo pipefail

# Constants
ISTORE_REPO="https://istore.istoreos.com/repo/all/store"
REPO_DOMAIN_OLD="istore.linkease.com"
REPO_DOMAIN_NEW="istore.istoreos.com"
TEMP_OPKG="/tmp/is-opkg"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Functions
error() {
  echo -e "${RED}[ERROR]${NC} $1" >&2
  exit 1
}

warning() {
  echo -e "${YELLOW}[WARNING]${NC} $1" >&2
}

info() {
  echo -e "${GREEN}[INFO]${NC} $1"
}

check_prerequisites() {
  # Check if running on OpenWrt
  if [ ! -f "/etc/openwrt_release" ]; then
    error "This script must be run on an OpenWrt system!"
  fi

  # Check for root
  if [ "$(id -u)" -ne 0 ]; then
    error "This script must be run as root!"
  fi

  # Check for curl
  if ! command -v curl >/dev/null 2>&1; then
    info "Installing curl..."
    opkg update || warning "Failed to update package lists"
    opkg install curl || error "Failed to install curl"
  fi
}

download_istore() {
  info "Downloading iStore package information..."
  IPK=$(curl --fail --show-error "$ISTORE_REPO/Packages.gz" | \
    zcat | \
    grep -m1 '^Filename: luci-app-store.*\.ipk$' | \
    sed -n -e 's/^Filename: \(.\+\)$/\1/p')

  [ -n "$IPK" ] || error "Failed to find iStore package in repository"

  info "Downloading and extracting iStore installer..."
  curl --fail --show-error "$ISTORE_REPO/$IPK" | \
    tar -xzO ./data.tar.gz | \
    tar -xzO ./bin/is-opkg > "$TEMP_OPKG" || \
    error "Failed to download or extract iStore installer"

  [ -s "$TEMP_OPKG" ] || error "Downloaded installer is empty"
  chmod 755 "$TEMP_OPKG"
}

install_packages() {
  info "Updating package lists..."
  "$TEMP_OPKG" update || warning "Package list update failed"

  info "Installing dependencies..."
  "$TEMP_OPKG" opkg install --force-reinstall luci-lib-taskd luci-lib-xterm || \
    error "Failed to install dependencies"

  info "Installing luci-app-store..."
  "$TEMP_OPKG" opkg install --force-reinstall luci-app-store || \
    error "Failed to install luci-app-store"

  if [ ! -s "/etc/init.d/tasks" ]; then
    info "Installing taskd..."
    "$TEMP_OPKG" opkg install --force-reinstall taskd || \
      warning "Failed to install taskd"
  fi

  if [ ! -s "/usr/lib/lua/luci/cbi.lua" ]; then
    info "Installing luci-compat..."
    "$TEMP_OPKG" opkg install luci-compat >/dev/null 2>&1 || \
      warning "Failed to install luci-compat"
  fi
}

update_repo_urls() {
  info "Updating repository URLs..."
  for file in /bin/is-opkg /etc/opkg/compatfeeds.conf /www/luci-static/istore/index.js; do
    if [ -f "$file" ]; then
      sed -i "s/$REPO_DOMAIN_OLD/$REPO_DOMAIN_NEW/g" "$file" || \
        warning "Failed to update $file"
    else
      warning "File not found: $file (skipping URL update)"
    fi
  done
}

cleanup() {
  if [ -f "$TEMP_OPKG" ]; then
    rm -f "$TEMP_OPKG" || warning "Failed to remove temporary file"
  fi
}

# Main execution
main() {
  info "Starting iStore installation..."
  
  check_prerequisites
  download_istore
  install_packages
  update_repo_urls
  cleanup
  
  info "iStore installation completed successfully!"
  info "You can now access iStore through the LuCI web interface."
}

# Execute main function
main