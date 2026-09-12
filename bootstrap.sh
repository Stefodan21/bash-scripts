#!/bin/bash
# Fedora/RHEL Main Bootstrap Script (multi-line loop)

set -e
[ "$EUID" -ne 0 ] && echo "Run as root or with sudo" && exit 1

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

BOOTSTRAP_SCRIPTS=(
    "packagebootstrap.sh"
    "networkbootstrap.sh"
    "databasebootstrap.sh"
    # "securitybootstrap.sh" 
)

for script in "${BOOTSTRAP_SCRIPTS[@]}"
do
    path="${SCRIPT_DIR}/${script}"
    if [ -f "$path" ]; then
        bash "$path"
    else
        echo "Error: $script not found"
    fi
done

echo "All bootstrap scripts completed successfully!"
