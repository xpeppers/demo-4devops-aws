# ECS and Docker ch

## Setting up the environment

1. install `awscli` http://docs.aws.amazon.com/cli/latest/userguide/installing.html
2. install `ecs-cli` http://docs.aws.amazon.com/AmazonECS/latest/developerguide/ECS_CLI_installation.html
3. install `jq` 

## On dev - work with your app in the dev

The app folder contains the sourcecode, the Dockerfile is a flask app with an health-check.

1. `docker-compose up --build`.
2. Open `http://localhost:8080`
3. Modify the string in `app/app.py:12` then you will see modification immediately.

## Test if it works

`curl -sL -w "%{http_code}\n"  http://0.0.0.0:80/`

> Hello! I am tiny service on <br> Hostname:"255edaace911"<br> Color:"green"<br> Version:"latest"<br> Visit count:171 times.
> 200

## Docker-compose.prod

- Variables
- Image repository
- Constrains

## Image repository

Configure the AWS cli and set the profile in Env.

`export AWS_PROFILE=ch4devops`

### Create the private repository 

`aws ecr create-repository --repository-name xpeppers/aws-ecs-4devops > config/ecr_repository.json`

``` json
{
    "repository": {
        "registryId": "xxxxxxxx",
        "repositoryName": "xpeppers/aws-ecs-4devops",
        "repositoryArn": "arn:aws:ecr:us-east-1:xxxxxxx:repository/xpeppers/aws-ecs-4devops",
        "createdAt": 1493209368.0,
        "repositoryUri": "xxxxxxx.dkr.ecr.us-east-1.amazonaws.com/xpeppers/aws-ecs-4devops"
    }
}
```

then:

```
jq ".repository.repositoryUri" -r config/ecr_repository.json
```

> xxxxxxxxx.dkr.ecr.us-east-1.amazonaws.com/xpeppers/aws-ecs-4devops

### Show all the images

```
aws ecr list-images --repository-name `jq ".repository.repositoryName" -r config/ecr_repository.json`

```

``` json
{
    "imageIds": [
        {
            "imageTag": "v1", 
            "imageDigest": "sha256:ccf3adf9fedb0bbc1460d133768e2cffba33e598677ff9373734ecb5d096d882"
        }, 
        {
            "imageTag": "latest", 
            "imageDigest": "sha256:ccf3adf9fedb0bbc1460d133768e2cffba33e598677ff9373734ecb5d096d882"
        }
    ]
}
```

## Tag and Build


### Manually create tag and push to the repository

The file `.env` contain the default tag, but in the real world app, we need to increase the value.

1. `chmod +x /script/increment-tag.sh && ./script/increment-tag.sh`

   > ➜ 0.0.2
   
2. `export TAG=$(./script/increment-tag.sh) || echo "version $TAG already exists"`

Our new tag is on $TAG variable

3. docker-compose build && docker-compose push

   > ➜  aws-ecs-4devops git:(master) ✗ docker-compose push                                                               
     Pushing web (xpeppers/aws-ecs-4devops:0.0.2)...

4. tag and push latest.

### Automatically run the script.

`./script/build.sh`

## Create Cluster

```
export CLUSTER=`jq ".cluster" -r config/env.json`

aws cloudformation create-stack \
   --stack-name $CLUSTER  \
   --template-body file://./infrastructure-ecs/ecs.json \
   --parameters file://./infrastructure-ecs/parameters.json
```


```
export ELB=`jq ".elb" -r config/env.json`

aws cloudformation create-stack \
    --stack-name $ELB \
     --template-body file://./infrastructure-alb/alb.json \
     --parameters file://./infrastructure-alb/parameters.json
```

## Create Task

`ecs-cli compose -f docker-compose.prod.yml -p ch create`

## Create Service with LB

```
CLUSTER=`jq ".cluster" -r config/env.json`
TASK=`jq ".task" -r config/env.json`
SERVICE=`jq ".service" -r config/env.json`
ARN=`jq ".elbArn" -r config/env.json`

aws --profile ch4devops ecs create-service \
   --service-name "$SERVICE" --cluster $CLUSTER \
   --task-definition ecscompose-ecscompose-ecs-demo \
   --load-balancers "targetGroupArn=$ARN,containerName=web,containerPort=80" --desired-count 2 --deployment-configuration "maximumPercent=200,minimumHealthyPercent=50" --role ecsServiceRole
```

"New deploy :)"

```
ecs-cli compose -p ch create
aws ecs update-service --service $SERVICE --cluster $CLUSTER --task-definition "$TASK" --desired-count 2 --deployment-configuration "maximumPercent=200,minimumHealthyPercent=100"
```

## Create Log 

```
aws logs create-log-group --log-group-name `jq ".log" -r config/env.json`
```

## Move all the static folders to  s3

aws --profile ch4devops s3  mv few s3://few-junglepass  --acl public-read --recursive
aws --profile ch4devops s3  mv admin s3://admin-junglepass  --acl public-read --recursive
aws --profile ch4devops s3  mv merchant s3://merchant-junglepass  --acl public-read --recursive

## Automate explicitly all the use cases

read the `script` folder.   