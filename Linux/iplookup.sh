#!/bin/bash

#script to identify the country from the IP addresses

curl -s http://ipinfo.io/$1 | grep country | awk -F: '{print $2}'

#Run the following three commands to confirm the script can identify the country from the IP addresses:

#eg:sh IP_lookup.sh  133.18.55.255

