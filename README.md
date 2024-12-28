# local_unbound_mint
### **For Linux Mint workstations (and various Debian/Ubuntu flavors)
This is an installation and configuration script for a local Unbound recursive DNS resolver with ad blocking functionality.

The installation script installs the latest version of Unbound from the ``apt`` utility. It modifies the configuration files for Unbound, NetworkManager and resolv.conf, so the default DNS resolver changes to localhost. It adds a weekly cronjob to retrieve a list of ad/malicious domains which should be blackholed. It runs the cronjob once to get a valid adhosts.block file, and restarts the NetworkManager and Unbound services.

<ins>__This Unbound configuration is opinionated:__</ins> it is designed for a single-user multicore workstation with about 400 MB of RAM sitting around. It uses Quad9 and Cloudflare for forwarded DNS queries. Please see get_adhosts.sh and the configuration files included in this repository. Confirm they suit your needs. Fork if not desirable.

Please see the license file for this repository. Use scripts from the Internet at your own risk, and perform regular backups to avoid data loss.

### Usage Instructions
Navigate to a home directory, or wherever you keep local copies of repositories. For example:

```
$ cd
$ mkdir sources
$ cd sources
```

Copy this repository so it can be updated when things change:
```
$ git clone https://github.com/b-etz/local_unbound_mint.git
$ cd local_unbound_mint
$ sudo ./install.sh
```
Enter the sudo password and wait for the script to complete.

### Testing the Installation
Use net tools to check DNS resolution settings. Many distributions come with a ``dig`` command, or ``nslookup``. If not, you may need to install ``dnsutils`` or ``bind9-dnsutils``.
```
$ dig example.com
```
This should use 127.0.0.1 to resolve the DNS query.
If you run the same ``dig`` command a second time, it should resolve in 0 ms.

### Update Instructions
If this tool has had a new revision and you want to adopt the changes:
```
$ cd ~/sources/local_unbound_mint
$ git pull
$ sudo ./install.sh
```
Enter the sudo password and wait for the script to complete.
