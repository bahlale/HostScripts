#ip a |grep inet | grep "/" | cut -d'/' -f1 | sed s/'    inet '//g | grep -v inet | sort -n > iplist #GET THE LIST OF IP ADDRESSES FROM THE SERVER
# ^  No need to check all the IP addresses on the server, using the active IP addresses is enough


#grep virtualhost /hsphere/shared/apache/conf/sites/*.conf  -i | grep ":8" | cut -d':' -f2 | cut -d' ' -f2 | uniq > iplist
# ^ Not using this as it contained duplicate values

find . -type f -iname 'wp-config.php' > list
#Get the list of wordpress directories from the data directory

grep virtualhost /hsphere/shared/apache/conf/sites/*.conf  -i | grep ":8" | cut -d':' -f2 | cut -d' ' -f2 | sort -u > iplist
#Active list of IP addresses from /hsphere/shared/apache/conf/sites/ directory


for i in `cat list`
do
p=$(echo $i | sed s/'\/wp-config.php'//g ) #REMOVE THE TRAILING CONFIG FILE PATH
#echo $p

ftphome=$(echo $i | cut -d'/' -f2) #EXTRACT THE FTP USER NAME FROM THE PATH
#echo $ftphome

domain=$(echo $i | cut -d'/' -f3) #EXTRACT THE DOMAIN NAME FROM THE PATH
#echo $domain


version=$(grep "wp_version =" $p/wp-includes/version.php | cut -d' ' -f3 | tr -d ';' | tr -d "'" |  tr -d '\r') #NOW EXTRACT THE WORDPRESS VERSION FROM THE CONFIG FILE

#echo -e $p '\t\t'  $version


ipaddr=$(host -t A $domain| cut -d' ' -f4)  #GET THE IP ADDRESS OF THE DOMAIN TO CHECK IF IT IS HOSTED ON THIS SERVER
ip=$(echo $ipaddr |  sed 2d | cut -d' ' -f1)
#echo $ip

if [ $ip == 'found:' ]
then
    ip="DNE"
    continue
fi

found='False'
for j in `cat iplist`
        do
                if [ "$j" == "$ip" ]
                then
                        found='True'
                        break
                fi
        done

echo -e $domain '\t\t\t'$version '\t\t' $ip '\t\t' $found '\t\t' $p


done
