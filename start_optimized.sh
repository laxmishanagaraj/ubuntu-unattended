#!/bin/bash
set -e

# set defaults
default_hostname="$(hostname)"
default_domain="laxmishanagaraj.local"
default_puppetmaster="foreman.laxmishanagaraj.nl"
tmp="/root/"

clear

# update repos
apt-get -y update
apt-get -y upgrade
apt-get -y dist-upgrade
apt-get -y autoremove
apt-get -y purge

# check for root privilege
if [ "$(id -u)" != "0" ]; then
   echo " this script must be run as root" 1>&2
   echo
   exit 1
fi

# define download function
# courtesy of http://fitnr.com/showing-file-download-progress-using-wget.html
download()
{
    local url=$1
    echo -n "    "
    wget --progress=dot $url 2>&1 | grep --line-buffered "%" | \
        sed -u -e "s,\.,,g" | awk '{printf("\b\b\b\b%4s", $2)}'
    echo -ne "\b\b\b\b"
    echo " DONE"
}

# determine ubuntu version
ubuntu_version=$(lsb_release -cs)

# check for interactive shell

# print status message
echo " preparing your server; this may take a few minutes ..."

# set fqdn
fqdn="$hostname.$domain"

# update hostname
echo "$hostname" > /etc/hostname
sed -i "s@ubuntu.ubuntu@$fqdn@g" /etc/hosts
sed -i "s@ubuntu@$hostname@g" /etc/hosts
hostname "$hostname"

# remove myself to prevent any unintended changes at a later stage
rm $0

# finish
echo " DONE; rebooting ... "

# reboot
reboot
