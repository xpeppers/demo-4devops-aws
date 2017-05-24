#!/usr/bin/env bash

`aws ecr get-login` || exit 1

export TAG=$(./script/increment-tag.sh) || echo "version $TAG already exists"
echo $TAG;

export REGISTRY=`jq ".repository.repositoryUri" -r config/ecr_repository.json`
export PROJECT=`jq ".task" -r config/env.json`
echo $REGISTRY:$TAG
ecs-cli compose -f docker-compose.prod.yml -p ${PROJECT-task} create

exit $?