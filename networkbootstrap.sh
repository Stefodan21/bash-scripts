#!/bin/bash
# Network Bootstrap Script (Fedora/RHEL version)
# Installs network diagnostics tools and configures Apache/Nginx

set -e
[ "$EUID" -ne 0 ] && echo "Run as root or with sudo" && exit 1

# Log everything for VMSS debugging
exec > >(tee -i /var/log/networkbootstrap.log)
exec 2>&1

echo "Starting network bootstrap..."
dnf -y update

###############################################
# Network Diagnostics Tools
###############################################
dnf -y install \
    net-tools bind-utils traceroute tcpdump nmap nmap-ncat \
    bridge-utils ethtool iftop nethogs mtr whois iproute \
    NetworkManager NetworkManager-wifi iw iputils socat

###############################################
# Web Servers (Networking Layer)
###############################################
# Apache
dnf -y install httpd
# systemctl enable --now httpd   # optional

# Nginx
dnf -y install nginx
# systemctl enable --now nginx   # optional

echo "Network bootstrap completed successfully!"
