#!/bin/bash

# Install Unbound or upgrade to the latest package
apt update
apt install -y unbound

# Create or replace Unbound's configuration files
cp -fv local.conf /etc/unbound/unbound.conf.d

# Create or replace the adblock list retrieval script
mkdir -pv /etc/unbound/logs/
cp -fv get_adhosts.sh /etc/cron.weekly
chmod +x /etc/cron.weekly/get_adhosts.sh
# Generate adhosts.block and check Unbound's configuration
/bin/bash /etc/cron.weekly/get_adhosts.sh

# Update NetworkManager and systemd-resolved configuration
cp -fv unbound-net-man.conf /etc/NetworkManager/conf.d
systemctl restart NetworkManager
systemctl stop systemd-resolved
systemctl disable systemd-resolved

# Update the DNS resolver configuration
chmod -x /etc/resolvconf/update.d/unbound
rm -fv /etc/resolv.conf
cp -fv resolv.conf /etc

# Restart Unbound and enable it on reboot
systemctl restart unbound
systemctl enable unbound

exit 0
#EOF
