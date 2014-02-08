HSP=~cpanel/shiva/psoft_config/hsphere.properties
DB_USER=`grep ^DB_USER $HSP|awk '{print $3}'`
PGPASSWORD=`grep ^DB_PASSWORD $HSP|awk '{print $3}'`
DB_NAME=hsphere
ACCOUNT_ID=291565
CPNAME="magweb"
MYSQL_SERVER="205.209.121.12"
#GET PARENT_ID FOR THE ACCOUNT
        PARENT_ID=`cat << EOF | psql -q -U $DB_USER $DB_NAME
        \pset t
        select DISTINCT  parent_id  from parent_child where account_id = $ACCOUNT_ID and child_type=6001`
#FIND THE DATABASES IN THE ACCOUNT
        echo `cat << EOF | psql -q -U $DB_USER $DB_NAME
        \pset t
        select db_name from mysqldb where parent_id=$PARENT_ID` > dbs_$ACCOUNT_ID
#FIND THE DATABASE USERS OF THE ACCOUNT
        echo `cat << EOF | psql -q -U $DB_USER $DB_NAME
        \pset t
        select login from mysql_users where parent_id = $PARENT_ID` >mysqlusers
        echo `cat << EOF | psql -q -U $DB_USER $DB_NAME
        \pset t
        select password from mysql_users where parent_id = $PARENT_ID` >mysqlpass
#FIND THE IP ADDRESS OF THE MYSQL SERVER TO FIND MYSQL USER FOR A DB
        IP=`cat << EOF | psql -q -U $DB_USER $DB_NAME
        \pset t
        select ip1 from p_server where id = (select p_server_id from l_server where id = (select mysql_host_id from mysqlres where id = $PARENT_ID))`
echo>mysqlusers1>mypass1>login>total>mapping
for i in `cat mysqlusers`
do
echo $i >> mysqlusers1
done
for j in `cat mysqlpass`
do
echo $j >> mypass1
done
paste mysqlusers1 mypass1 -d ' ' > login
for i in `cat dbs_$ACCOUNT_ID`
do
        users=$(ssh -l root $IP /hsphere/shared/scripts/mysql-db-users $i)
        for j in `echo $users`
        do
                #echo User for $i is $j
                pass=$(grep $j login | cut -d' ' -f2)
                t=$(echo $j | cut -d'_' -f2 ) #REMOVING THE PREFIX
                j=$(echo ${t:0:8}) #LIMIT DBUSER TO 7 CHARACTERS
                dbusert=$(echo -e $CPNAME"_"$j) #ADDING CPANEL PREFIX TO DBUSER
                dbuser=$(echo ${dbusert:0:16}) #LIMIT DBUSER to 16 characters
                t=$(echo $i | cut -d'_' -f2 )
                dbname=$(echo -e $CPNAME"_"$t)
                 mysql -h $MYSQL_SERVER  -u root -p`cat pwd` -e "create database $dbname"
                mysql -h $MYSQL_SERVER  -u root -p`cat pwd` -e "create user $dbuser"
                mysql -h $MYSQL_SERVER -u root -p`cat pwd` -e "grant all privileges on $dbname.* to $dbuser@'%' identified by '$pass'"
                echo -e "/usr/local/cpanel/bin/dbmaptool $CPNAME --type mysql --dbusers '$dbuser' --dbs '$dbname' " >>mapping
        done
done
scp mapping root@205.209.121.3:/root/
ssh root@205.209.121.3 chmod +x  /root/mapping
ssh root@205.209.121.3 /root/mapping
