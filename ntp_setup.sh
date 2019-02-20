#!/bin/bash

# Install update repo and install NTP, ntpdate
echo " **** Updating and installing ntp **** "
sudo apt install -y ntp ntpdate

# Check and make a back up for /etc/ntp.conf file
if [ ! -f  "/etc/ntp.conf.bak" ]; then cp /etc/ntp.conf /etc/ntp.conf.bak; echo 'NOTICE: ntp.conf.bak created..'; fi

# Configuring /etc/ntp.conf to add time server to point to
echo ' **** Configuring /etc/ntp.conf **** '
# Variables
SERVER1='time.nist.gov'
SERVER2='pool.ntp.org'
IP="$(grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' /etc/hosts | head -1)"
sed -i 's/^server/#server/g' /etc/ntp.conf
sed -i 's/^pool/#pool/g' /etc/ntp.conf
echo "server $SERVER1 iburst" >> /etc/ntp.conf
echo "server $SERVER2 iburst" >> /etc/ntp.conf
echo  "restrict $IP mask 255.255.255.0 nomodify notrap" >> /etc/ntp.conf

# Run against the time server to sync
echo " **** Stopping ntpd for a minute **** "
service ntpd stop >> /dev/null 2>&1

echo " **** Restarting ntpd  **** "
# restarting ntp
service ntp start

# using ntpdate to sync with time servers
echo " **** Doing Initial Synchronization **** "
ntpdate -q $SERVER1
ntpdate -q $SERVER2

# More Variables
result=$(ntpq -nc peers)
offsets=$(ntpq -nc peers | tail -n +3 | cut -c 62-70 | tr -d '-')
limitvalue=1000
log_file=/var/log/ntp.serverlog
echo " **** Getting result **** "
echo "Current system date and time: "
echo "$(date)"
echo " ********  ********  ******* ********** "
for offset in ${offsets}; do

    echo "Offsets values: $offset" | tee -a $log_file

    if [ $offset -ge $limitvalue} >> /dev/null 2>&1 ]; then
        echo "An NTPD offset is more than 1 sec - Sync again"
        exit 1
    else
        echo "Offset value of $offset is normal (less than 1000 milisec)"
    fi
done

echo " ********  ********  ******* ********** "

#save the result of ntp query logged in /var/log/ntp.serverlog
echo "Result:   (It is also logged in the /var/log/ntp.serverlog) "
echo "$result" | tee -a $log_file

echo " ********  ********  ******* ********** "
# EOF
