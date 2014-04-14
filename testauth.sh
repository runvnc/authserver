#!/bin/bash
#set -x
curl --data "user=bob&password=password" http://localhost:5000/newuser
curl --data "user=bob&password=password" http://localhost:5000/checkpassword
curl --data "user=bob&password=wrongpassword" http://localhost:5000/checkpassword
access=`curl --get --data "user=bob&password=password" http://localhost:5000/accesstoken | xargs echo -n`
access="${access%?}"
echo "Access token is $access"
echo "hexdump of access token is:"
echo $access>token
hexdump -c token
curl -G "http://localhost:5000/verifytoken?token=$access"
