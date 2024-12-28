#!/bin/bash
_tmp=$(mktemp)
_out="/etc/unbound/unbound.conf.d/adhosts.block"
_logfile="/etc/unbound/logs/adhosts_log_$(date +"%Y-%m-%d_%H%M%S").log"

function adguardhome { # Same lists as AdGuard
	# AdGuard DNS Filter
	_src="https://adguardteam.github.io/AdGuardSDNSFilter/Filters/filter.txt"
	wget -a "$_logfile" -O - "$_src" | \
		sed -nre 's/^\|\|([a-zA-Z0-9\_\-\.]+)\^$/local-zone: "\1" always_nxdomain/p'

	# AdAway default blocklist
	_src="https://adaway.org/hosts.txt"
	wget -a "$_logfile" -O - "$_src" | \
		awk '/^127.0.0.1 / { print "local-zone: \"" $2 "\" always_nxdomain" }'
}

function stevenblack { # Same lists as PiHole
	_src="https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"
	wget -a "$_logfile" -O - "$_src" | \
		awk '/^0.0.0.0 / { print "local-zone: \"" $2 "\" always_nxdomain" }'
}

function ublockorigin { # Same lists as uBlock Origin, but without browser plugin
	# Malicious domains
	_src="https://malware-filter.gitlab.io/malware-filter/urlhaus-filter-unbound.conf"
	wget -a "$_logfile" -O - "$_src" | grep '^local-zone: '

	# Peter Lowe's list
	_src="https://pgl.yoyo.org/adservers/serverlist.php?showintro=0;hostformat=hosts"
	wget -a "$_logfile" -O - "$_src" | \
		awk '/^127.0.0.1 / { print "local-zone: \"" $2 "\" always_nxdomain" }'
}

function stopforumspam { # StopForumSpam list
	_src="https://www.stopforumspam.com/downloads/toxic_domains_whole.txt"
	wget -a "$_logfile" -O - "$_src" | \
		awk '{ print "local-zone: \"" $1 "\" always_nxdomain" }'
}

function adblockplus { # OISD is the AdBlock Plus filter list
	_src="https://big.oisd.nl/"
	wget -a "$_logfile" -O - "$_src" | \
		sed -nre 's/^\|\|([a-zA-Z0-9\_\-\.]+)\^$/local-zone: "\1" always_nxdomain/p'
}

# You can add many (b)ad host lists. Many are updated regularly on GitHub, etc.
# Comment out any lines you don't want, or add more below:
adguardhome >> "$_tmp"
stevenblack >> "$_tmp"
ublockorigin >> "$_tmp"
stopforumspam >> "$_tmp"
adblockplus >> "$_tmp"

# Clean up
sed -re 's/\.\" always/" always/' "$_tmp" | \
	grep -v "t\.co\|\\\\" | \
	sort -u -o "$_tmp"
chmod 0644 "$_tmp"

# If there are different entries, update
diff -Nq "$_out" "$_tmp" 1>>"$_logfile"
case $? in
	0) rm "$_tmp" && exit 0;; # No changes
	1) mv -fu "$_tmp" "$_out";;
	*) echo "$0: something bad happened!"; exit 1;;
esac
unbound-checkconf 2>&1 | tee -a "$_logfile"
exec unbound-control reload_keep_cache 2>&1 | tee -a "$_logfile"
exit 0
#EOF