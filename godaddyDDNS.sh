#!/bin/bash

# This script is used to check and update your GoDaddy DNS server to the IP address of your current internet connection.
# Special thanks to mfox for his ps script
# https://github.com/markafox/GoDaddy_Powershell_DDNS
#
# First go to GoDaddy developer site to create a developer account and get your key and secret
#
# https://developer.godaddy.com/getstarted
# Be aware that there are 2 types of key and secret - one for the test server and one for the production server
# Get a key and secret for the production server
# 
#Update the first 4 variables with your information


# Add below two lines in crontab entry.
## */5 * * * * ~/godaddy/godaddyDDNS.sh >/dev/null 2>&1  ##
## @reboot ~/godaddy/godaddyDDNS.sh >/dev/null 2>&1  ##


DIR=$(cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd)  				#Present directory of this file
properties_file="$DIR/godaddyDDNS.properties"							#Properties file to store value of domain, subdomain, keys and others
domain="$(grep -i domain "$properties_file"|tail -1|awk -F "=" '{print $2}')"  			#domain name
name="$(grep -i name "$properties_file"|tail -1|awk -F "=" '{print $2}')"			#sub-domain
key="$(grep -i key "$properties_file"|tail -1|awk -F "=" '{print $2}')"				#godaddy developer key
secret="$(grep -i secret "$properties_file"|tail -1|awk -F "=" '{print $2}')"			#godaddy developer secret

headers="Authorization: sso-key $key:$secret"

# echo $headers

result=$(curl -s -X GET -H "$headers" \
 "https://api.godaddy.com/v1/domains/$domain/records/A/$name")

dnsIp=$(echo $result | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b")
# echo "dnsIp:" $dnsIp

# Get public ip address there are several websites that can do this.
ret=$(curl -s GET "http://ipinfo.io/json")
currentIp=$(echo $ret | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b")
# echo "currentIp:" $currentIp

 if [ "$dnsIp" != $currentIp ];
 then
#	echo "Ips are not equal"
	request='{"data":"'$currentIp'","ttl":3600}'
#	echo $request
	nresult=$(curl -i -s -X PUT \
 -H "$headers" \
 -H "Content-Type: application/json" \
 -d [$request] "https://api.godaddy.com/v1/domains/$domain/records/A/$name")
	if [ ! -z "$nresult" ]
	then
		echo "KO" > godaddyDDNS.log
	else
		echo "OK" > godaddyDDNS.log
	fi
 else
	#echo "Ips are equal"
	echo "OK" > godaddyDDNS.log
fi
