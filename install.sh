#!/bin/bash

# Install Unbound or upgrade to the latest package
apt update
apt install -y unbound

# Create or replace Unbound's configuration files
cp -f local.conf /etc/unbound/unbound.conf.d

# Create or replace the adblock list retrieval script
mkdir -p /etc/unbound/logs/
cp -f get_adhosts.sh /etc/cron.weekly
chmod +x /etc/cron.weekly/get_adhosts.sh
# Generate adhosts.block and check Unbound's configuration
/bin/bash /etc/cron.weekly/get_adhosts.sh

# Update NetworkManager's configuration
cp -f unbound-net-man.conf /etc/NetworkManager/conf.d
systemctl restart NetworkManager

# Update the DNS resolver configuration
chmod -x /etc/resolvconf/update.d/unbound
cp -f resolv.conf /etc

# Restart Unbound and enable it on reboot
systemctl restart unbound
systemctl enable unbound

exit 0
#EOF