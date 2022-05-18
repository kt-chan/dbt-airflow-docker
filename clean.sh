#!/usr/bin/env bash

#docker-compose down --rmi all --volumes 
docker-compose down

if [[ -n $(docker volume ls -q) ]]; then
	docker volume rm $(docker volume ls -q)
fi



