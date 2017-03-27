function select-dbsrv() {
#!/bin/bash
#Selecting Database Server
clear
while [[ "$REPLY" != 1 && "$REPLY" != 2 && "$REPLY" != 0 ]]
do
        echo "
Please select Database Server type that you want to configure
  1. Mysql
  2. PostgreSQL
  0. Quit
        "
	read -p "Enter selection [0-2] > "
done
case $REPLY in
        1) mysql_configure ;;
        2) pgsql_configure ;;
	0) echo "Bye bye"
	exit 1;;
	*) echo "Please select [0-2]" ;;
esac
}
#MYSQL INSTALLATION
function mysql_configure() {
echo "You selected MySQL database server to configure"
sleep 1
UP=$(pgrep mysql | wc -l);
if [ "$UP" -eq 0 ];
then
	echo "MySQL server is not running. Trying to start MySql server..."
	sleep 1
	service mysqld start
	while [ $? != 0 ]; do
		echo "Probably MySql is not installed in your machine"
        	echo -n "Would you like to install it [y/n]: "
		read ANSWER
		case $ANSWER in
		y)
			yum install mysql mysql-server -y
			service mysqld start &&
			echo "Mysql-server started"
			sleep 1	;;
		n)
			echo "Bye-Bye"
			exit 0 ;;
		*)
			echo "please input "y" or "n"" ;;
		esac
	done
else
	echo "Mysql Server is running"
	sleep 1
fi

if ! echo quit | mysql -uroot 2> /dev/null; then
while true; do
	echo -n Please enter current mysql root password:
        read -s mysqlpass1
        if echo quit | mysql -uroot -p$mysqlpass1 2> /dev/null
        then
                echo -e "\nMySQL ROOT Password is correct\n"
		break
        else
                echo -e "\nPassword is incorrect\n"
		echo -e "\n[1] Reset root password of Mysql\n[2] Retry"
	        echo -n "Please select [1] or [2]:"
        	read mysql_menu
		case $mysql_menu in
			1)
			./mysqlpass-remove.sh &&
			set_mysql_pass && break
			;;
			*)
			echo "Please try again"
			;;
		esac
	fi
done
else
	set_mysql_pass
fi

while true; do
	echo -n "Would you like create new database?[y/n]:"
        read ANSWER
        case $ANSWER in
        	y)
		create_mysql_db ;;
        	n)
        	echo "Bye-Bye"
        	exit 0 ;;
       		*)
        	echo "please input "y" or "n"" ;;
        esac
done

}
function set_mysql_pass() {
echo "Configuring MySQL..."
echo "Please enter NEW root password for Mysql database:"
echo -n Password:
read -s mysqlpass1
echo
echo -n "Please re-enter password:"
read -s mysqlpass2
echo
sleep 2
if [ $mysqlpass1 = $mysqlpass2 ]; then
        echo -e "\n\n$mysqlpass1\n$mysqlpass1\n\n\n\n\n" | mysql_secure_installation
else
        echo "Passwords do not match"
        sleep 1
fi
}
function create_mysql_db() {
echo -e "\n\nCreating database\n\n"
sleep 2
echo -n "Please enter database name:  "
read DBNAME
echo
echo -n "Please enter username:  "
read DBUSER
echo
echo -n "Please enter password for user "$DBUSER":  "
read -s DBPASS
echo
mysql -uroot -p$mysqlpass1 -e "CREATE DATABASE $DBNAME;"
mysql -uroot -p$mysqlpass1 -e "GRANT ALL ON $DBNAME.* TO '$DBUSER'@'localhost' IDENTIFIED BY '$DBPASS';"
mysql -uroot -p$mysqlpass1 -e "FLUSH PRIVILEGES;"
echo "MySQL database and user created."
echo "DB name:    $DBNAME"
echo "Username:   $DBUSER"
echo "Password:   $DBPASS"
sleep 3
}

#POSTGRESQL INSTALLATION
function pgsql_configure() {
echo "You selected PostgreSQL database server to configure"
sleep 1
UP=$(pgrep postmaster | wc -l);
if [ "$UP" -eq 0 ]
then
	echo "PostgreSQL server is not running. Trying to start..."
	sleep 1
	service postgresql start
        while [ $? != 0 ]; do
                echo "Probably PostgreSQL is not installed in your machine"
                echo -n "Would you like to install it [y/n]: "
                read ANSWER
                case $ANSWER in
                y)
                        yum install postgresql postgresql-server -y
                        service postgresql initdb
			service postgresql start &&
                        echo "PostgreSQL-server started"
                        sleep 1 ;;
                n)
                        echo "Bye-Bye"
                        exit 0 ;;
                *)
                        echo "please input "y" or "n"" ;;
                esac
        done
else
        echo "PostgreSQL Server is running"
        sleep 1
fi
if ! echo '\q' | su -c "psql" - postgres 2> /dev/null; then
while true; do
        echo -n Please enter current PostgreSQL root password:
        read -s pgsqlpass1
        if echo $pgsqlpass1 |su -c "psql" - postgres -p 2> /dev/null
	then
                echo -e "\nPostgreSQL ROOT Password is correct\n"
                break
        else
                echo -e "\nPassword is incorrect\n"
                echo -e "\n[1] Reset root password of PostgreSQL\n[2] Retry"
                echo -n "Please select [1] or [2]:"
                read pgsql_menu
                case $pgsql_menu in
                        1)
                        ./pgsqlpass-remove.sh && sleep 1
                        set_pgsql_pass && break
                        ;;
                        2)
                        echo "Please try again"
                        ;;
                esac
        fi
done
else
        set_pgsql_pass
fi
while true; do
        echo -n "Would you like create new database?[y/n]:"
        read ANSWER
        case $ANSWER in
                y)
                create_pgsql_db ;;
                n)
                echo "Bye-Bye"
                exit 0 ;;
                *)
                echo "please input "y" or "n"" ;;
        esac
done
}
function set_pgsql_pass() {
while [ $pgsqlpass1 != $pgsqlpass2 ]
do
        echo "Configuring PostgreSQL..."
        echo "Please enter NEW root password for PostgreSql database:"
        echo -n Password:
        read -s pgsqlpass1
        echo
        echo -n "Please re-enter password:"
        read -s pgsqlpass2
        echo
        sleep 2
done
printf "\password\n$pgsqlpass1\n$pgsqlpass1\n\q" | su -c "psql" - postgres
pghbaconf=`find / -name pg_hba.conf 2> /dev/null`
pghbaconfset='./pghbaconf-set'
echo y | cp $pghbaconfset $pghbaconf
service postgresql reload
}
function create_pgsql_db() {
echo -e "\n\nCreating database\n\n"
sleep 2
echo -n "Please enter database name:  "
read DBNAME
echo
echo -n "Please enter username:  "
read DBUSER
echo
echo -n "Please enter password for user "$DBUSER":  "
read -s DBPASS
echo

printf "$pgsqlpass1\nCREATE USER $DBUSER WITH PASSWORD '$DBPASS';\nCREATE DATABASE $DBNAME;\nGRANT ALL PRIVILEGES ON DATABASE $DBNAME to $DBUSER;\n" | su -c "psql" - postgres -p

echo "PostgreSQL database and user created."
echo "DB name:    $DBNAME"
echo "Username:   $DBUSER"
echo "Password:   $DBPASS"
sleep 3
}
select-dbsrv
