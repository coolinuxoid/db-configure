#!/bin/bash
service mysqld stop
mysqld_safe --skip-grant-tables &
printf "use mysql;\nupdate user set password=PASSWORD("") where User='root';\nflush privileges;\nquit" | mysql -uroot
service mysqld stop
service mysqld start

