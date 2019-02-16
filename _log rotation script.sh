

#!/bin/bash
#log rotation script
# Assign variables
LOGDIR=/var/log/
LOGFILE=messages
#tar and archive messages file append date and time
tar -C $LOGDIR -cZf $LOGDIR/$LOGFILE.$(date +%Y%m%d_%T).tar.gz $LOGDIR/$LOGFILE
#change permission
chmod 644 $LOGDIR/$LOGFILE.*.tar.gz
#removing old files using find command -mmin +420( 60mins*7) for files older than 7 hours
# -delete option will delete the old files
find /var/log -name “messages.*.tar.gz” -type f -mmin +420 -delete
#I simply make crontab-e entries to run every 1 hour  :
* 1 * * * /bin/bash /usr/local/bin/log_rotation.sh
