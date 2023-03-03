#!/bin/bash
# unblacklist
# made by Jersey Shore Technologies <info@jstechnologies.net>
# maintained by HERMES42 <info@hermes42.com>
# V0.1b - 2019.03.05

#####################
# F U N C T I O N S #
#####################

# Test IP address for validity
# Usage: 
# validateIpAddress ip_addr
#
function validateIpAddress() {
	local ip=$1
	local result=1
	
	# Make sure the 4 octets are nothing but numbers	
	if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
	
		# Change temporarily the bash Internal Field Separator to a . (dot)
		IFS_temp=$IFS
		IFS='.'
		
		# Assign the value of the IP address to itself inside parenthesis in order to return an array
		ip=($ip)
		
		# Restore the IFS to bash original value
		IFS=$IFS_temp
		
		# Finally, make sure that each octet have a value lower than 255
		[[ ${ip[0]} -le 255 && ${ip[1]} -le 255 && ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]
		# and save the status of this test
		result=$?
	fi
	echo $result
}



# Get the database password for  phonesystem user
# Usage:
# getDBPassword
#
function getDBPassword() {
	# Get the password from 3CX File
	DBPassword=`grep MasterDBPassword /var/lib/3cxpbx/Bin/3CXPhoneSystem.ini|cut -d' ' -f3`
	
	if [[ $? -eq 1 ]]; then
		echo "I was unable to read the phonesystem user password."
		exit
	fi
}



# Check if the IP address is actually in the blacklisted database
# Usage:
# checkIpAddress ip_add
function deleteIpAddress() {
    getDBPassword
	psql postgresql://phonesystem:$DBPassword@127.0.0.1/database_single << EOF
delete from blacklist where ipaddr = '$ip_addr';
EOF
}




###########
# M A I N #
###########
# Ask for the IP address to delete
echo "unblacklist \V0.1b\ - March 2019"
read -p "Enter the IP address to remove from the blacklisted database: " ip_addr

# IP address check
if [[ $(validateIpAddress "$ip_addr") -eq 1 ]]; then
	echo "The IP address you entered is incorrect."
	exit
fi

# Look for the IP address in the database and delete it
deleteIpAddress $ip_addr

echo "If this was successful, you must restart the phone system MC01 service by entering the following command:"
echo "service 3CXPhoneSystemMC01 restart"
echo "Once the service is restarted, you may try to re-login through the web interface"
