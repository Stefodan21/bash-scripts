#!/bin/bash
# Database Bootstrap Script (Azure Table Storage version)
# Installs Azure CLI + Azure Storage SDKs (no local DB engines)

set -e
[ "$EUID" -ne 0 ] && echo "Run as root or with sudo" && exit 1

exec > >(tee -i /var/log/databasebootstrap.log)
exec 2>&1

echo "Starting Azure Table Storage bootstrap..."
dnf -y update

###############################################
# Azure CLI (required for Azure Table Storage ops)
###############################################
dnf -y install curl
curl -sL https://aka.ms/InstallAzureCLIDeb | bash || true

###############################################
# Azure Storage SDKs (Python + Node)
###############################################
dnf -y install python3 python3-pip nodejs

pip install azure-data-tables azure-storage-blob azure-storage-queue --break-system-packages
npm install -g @azure/data-tables @azure/storage-blob @azure/storage-queue

###############################################
# Optional: Storage Explorer (GUI)
###############################################
# Only install if DISPLAY exists (VM with GUI)
if [ -n "$DISPLAY" ]; then
    rpm --import https://packages.microsoft.com/keys/microsoft.asc
    cat <<EOF >/etc/yum.repos.d/msprod.repo
[msprod]
name=Microsoft Prod
baseurl=https://packages.microsoft.com/yumrepos/msprod/
enabled=1
gpgcheck=1
EOF
    dnf -y install storageexplorer
fi

echo "Azure Table Storage tools installed successfully!"
