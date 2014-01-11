# Build Domain list from Apache Config
domain_list(){

}

# Check New Domains
new_domain(){

}

# Check Domain IP
domain_ip(){

}

# Build IP List
server_IP_list(){
	grep virtualhost /hsphere/shared/apache/conf/sites/*.conf  -i | grep ":8" | \
	 cut -d':' -f2 | cut -d' ' -f2 | sort -u > /tmp/iplist.txt
}

# Check CMS for New Domain
# WordPress, Joomla, PHPBB
check_cms(){
# Will put on WP


}

# Send Mail
send_mail(){

}