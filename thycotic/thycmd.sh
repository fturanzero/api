#!/bin/bash

site='<url>'
pass='<pass>'
user=$1
secretid=$2
launcherid=$3
machine=$4

token_req="username=${user}&grant_type=password&password=${pass}"
launcher_req="{\"launcherid\":${launcherid},\"promptFieldValue\":\"${machine}\",\"secretid\":${secretid}}"

token=$(curl -s -k -X POST -H 'Content-Type: application/x-www-form-urlencoded' -d $token_req $site'/oauth2/token' | jq -r '.access_token')
ssUrl=$(curl -s -k -X POST -H 'Authorization: Bearer '$token -H $'Content-Type: application/json' -d $launcher_req $site'/api/v1/launchers/secret' | jq -r '.model.ssUrl')
$ssLink="sslauncher:///${ssUrl}"

echo ssLink
