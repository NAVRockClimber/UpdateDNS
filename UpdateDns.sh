#!/bin/bash

while [ $# -gt 0 ]  # While number of parameters ($#) greate 0
do 
  case $1 in
   -key) 
        key=$2;;
    -Hostname)
        Hostname=$2;;
    -AutoDetect)
        AutoDetect=$2;;
  esac         
  shift # Shift paramters $2->$1, $3->$2, $4->$3,...
done
 

baseUrl="<your Url>"
autocreate="true"
ResourceGroupName="<your Resource Group>"
ZoneName="your domain"

Header="x-functions-key: $key"


addrArray=$(ip -j address show eno1 | jq 'map(select(.[] | length > 0))' | jq '.[0].addr_info')
arrayLength=$(echo $addrArray|jq 'length')
n=0
while [  $n -lt $arrayLength ]; do
    scope=$(echo $addrArray | jq -r ".[$n].scope")
    family=$(echo $addrArray | jq -r ".[$n].family")
    ip=$(echo $addrArray | jq -r ".[$n].local")
    if [ $scope = global ] && [ $family = inet6 ]; then
        # echo $family $scope $ip
        Param6="AAAA=$ip&Hostname=$Hostname&autocreate=$autocreate&ResourceGroupName=$ResourceGroupName&ZoneName=$ZoneName"
        url6="$baseUrl?$Param6"
        response=$(curl -H "$Header" -X GET --write-out '%{http_code}' --silent $url6)
    fi
    let n+=1
done
if [ $AutoDetect = "true" ]; then
    # echo AutoDetect IPV4
    Param4="AutoDetect=$AutoDetect&Hostname=$Hostname&autocreate=$autocreate&ResourceGroupName=$ResourceGroupName&ZoneName=$ZoneName"
    url4="$baseUrl?$Param4"
    response=$(curl -H "$Header" -X GET --write-out '%{http_code}' --silent $url4)
fi