#!/bin/bash

#export IMAGE_TAG=2.0.0
export IMAGE_TAG=1.4
CMD="$1"
: ${CMD:="up"}
TYPE="$2"
: ${TYPE:="solo"}

echo 
echo "type: $TYPE"

function Start() {
  if [ "$TYPE" == "solo" ]; then
    docker-compose -f docker-compose-cli.yaml up -d
  elif [ "$TYPE" == "raft" ]; then
    docker-compose -f docker-compose-cli.yaml -f docker-compose-$tmp.yaml  up -d
  elif [ "$TYPE" == "kfk" ]; then
    docker-compose -f docker-compose-cli.yaml -f docker-compose-$tmp.yaml  up -d
  else
    echo "type error..."
  fi
}

function Stop() {
  if [ "$TYPE" == "solo" ]; then
    docker-compose -f docker-compose-cli.yaml down
  elif [ "$TYPE" == "raft" ]; then
    docker-compose -f docker-compose-raft.yaml -f docker-compose-etcdraft.yaml down
  else
    echo "Error Type"
    exit 1
  fi
  
  docker ps -a|grep "dev\-peer"|awk '{print $1}'| xargs docker rm -f 
  docker images |grep "^dev\-peer"|awk '{print $3}'|xargs docker rmi -f
}

if [ "$CMD" == "up" ]; then
  Start
elif [ "$CMD" == "down" ]; then
  Stop
else 
  echo "Error cmd"
  echo "example: ./$0 up solo"
  exit 1
fi

