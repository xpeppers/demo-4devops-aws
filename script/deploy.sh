#!/usr/bin/env bash

CLUSTER=`jq ".repository.cluster" -r config/env.json`
TASK=`jq ".repository.task" -r config/env.json`
SERVICE=`jq ".repository.service" -r config/env.json`

echo "Updating task service"
ecs-cli compose -p ch create

echo "Updating service"
aws ecs update-service --service $TASK --cluster $CLUSTER --task-definition "ecscompose-python-microservice-two" --desired-count 2 --deployment-configuration "maximumPercent=200,minimumHealthyPercent=100"
