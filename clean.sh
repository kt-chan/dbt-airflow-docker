#!/usr/bin/env bash

rm -rf ./airflow/*
mkdir ./airflow/dags
mkdir ./airflow/logs
mkdir ./airflow/plugins

#docker-compose down --rmi all --volumes 
docker-compose down
docker volume rm $(docker volume ls -q)



