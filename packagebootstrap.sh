#!/bin/bash
# Fedora/RHEL Package Bootstrap Script

set -e

# Must run as root
[ "$EUID" -ne 0 ] && echo "Run as root or with sudo" && exit 1

# Log everything for VMSS debugging
exec > >(tee -i /var/log/packagebootstrap.log)
exec 2>&1

echo "Starting package bootstrap..."
dnf -y update

###############################################
# Development Tools & Build Systems
###############################################
dnf -y group install development-tools
dnf -y install make cmake automake autoconf libtool pkgconfig

###############################################
# CLI Utilities
###############################################
dnf -y install git curl wget vim nano htop tmux screen tree jq bc file rsync unzip zip tar gzip bzip2

###############################################
# Languages & Compilers
###############################################
dnf -y install python3 python3-pip python3-virtualenv
dnf -y install golang
dnf -y install gcc-c++

# ###############################################
# # Node.js + TypeScript
# ###############################################
# dnf -y install nodejs
# npm install -g typescript

# ###############################################
# # HashiCorp Repo + Terraform
# ###############################################
# dnf -y install dnf-plugins-core
# curl -fsSL https://rpm.releases.hashicorp.com/fedora/hashicorp.repo \
#     -o /etc/yum.repos.d/hashicorp.repo
# dnf -y update
# dnf -y install terraform

###############################################
# Containers & Automation
###############################################
dnf -y install podman docker-compose ansible
systemctl enable --now podman

###############################################
# SSH Server (system-level, not security-hardening)
###############################################
dnf -y install openssh-server
systemctl enable --now sshd

###############################################
# SELinux Tools (system-level)
###############################################
dnf -y install policycoreutils-python-utils

###############################################
# Performance Tools (system-level)
###############################################
dnf -y install sysstat perf tuned tuned-utils
systemctl enable --now tuned

###############################################
# Azure VM Agent (VMSS requirement)
###############################################
dnf -y install WALinuxAgent
systemctl enable --now waagent


###############################################
# Cleanup
###############################################
dnf -y autoremove
dnf -y clean all

echo "Package bootstrap completed!"

