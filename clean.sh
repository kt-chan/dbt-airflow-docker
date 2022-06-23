#!/usr/bin/env bash

#docker-compose down --rmi all --volumes 
docker-compose down

if [[ -n $(docker ps -a -q) ]]; then
	docker rm -f $(docker ps -a -q)
fi

if [[ -n $(docker volume ls -q) ]]; then
	docker volume rm $(docker volume ls -q)
fi



