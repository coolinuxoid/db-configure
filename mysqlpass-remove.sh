#!/bin/bash
#This script included in db-configure.sh script but also could be used separetly
#to remove MySQL ROOT password
service mysqld stop
mysqld_safe --skip-grant-tables &
printf "use mysql;\nupdate user set password=PASSWORD("") where User='root';\nflush privileges;\nquit" | mysql -uroot
service mysqld stop
service mysqld start

