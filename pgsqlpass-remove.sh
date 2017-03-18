#!/bin/bash
#This script included in db-configure.sh script but also could be used separetly
#to remove PostgreSQL ROOT password
pghbaconf=`find / -name pg_hba.conf`
pghbaconfremove='./pghbaconf-remove'
pghbaconfset='./pghbaconf-set'
cp -v $pghbaconf $pghbaconf.bkp
echo y | cp $pghbaconfremove $pghbaconf
service postgresql reload
