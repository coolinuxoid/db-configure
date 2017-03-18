#!/bin/bash
pghbaconf=`find / -name pg_hba.conf`
pghbaconfremove='./pghbaconf-remove'
pghbaconfset='./pghbaconf-set'
cp -v $pghbaconf $pghbaconf.bkp
echo y | cp $pghbaconfremove $pghbaconf
service postgresql reload
