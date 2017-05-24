#!/usr/bin/env bash

LB=`jq ".elb" -r config/env.json`

while true;
do
    curl -sL -w "%{http_code}\n" ${LB}
done