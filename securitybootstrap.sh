#!/bin/bash
# Security Bootstrap Script (Fedora/RHEL)

set -e
[ "$EUID" -ne 0 ] && echo "Run as root or with sudo" && exit 1

exec > >(tee -i /var/log/securitybootstrap.log)
exec 2>&1

echo "Starting security bootstrap..."
dnf -y update

###############################################
# FirewallD (default zone: drop)
###############################################
dnf -y install firewalld
systemctl enable --now firewalld

# Set strict default zone
firewall-cmd --set-default-zone=drop

# Allow SSH only
firewall-cmd --permanent --zone=drop --add-service=ssh
firewall-cmd --reload

###############################################
# Fail2ban (SSH protection)
###############################################
dnf -y install fail2ban

cat > /etc/fail2ban/jail.local <<EOF
[DEFAULT]
bantime = 3600
findtime = 600
maxretry = 5

[sshd]
enabled = true
port = ssh
logpath = /var/log/secure
EOF

systemctl enable --now fail2ban

###############################################
# SSH Hardening (NOT installation)
###############################################
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup

# Disable root login
sed -i 's/^#PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config

# Ensure password auth is enabled (you can disable later if using keys)
sed -i 's/^#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Ensure pubkey auth is enabled
sed -i 's/^#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config

systemctl restart sshd

###############################################
# Security Tools (rootkit + antivirus)
###############################################
dnf -y install rkhunter chkrootkit lynis clamav clamav-update

# Freshclam may fail if rate-limited — ignore errors
systemctl stop clamav-freshclam || true
freshclam --quiet || echo "Warning: freshclam update failed"
systemctl start clamav-freshclam || true

###############################################
# Automatic Security Updates
###############################################
dnf -y install dnf-automatic
systemctl enable --now dnf-automatic.timer

echo "Security bootstrap completed!"
