#!/usr/bin/env bash

if [[ (! -z "$1") &&  ("$1" == "force") ]]; then

	docker build -f ./dockerfile/dockerfile_airflow -t airflow:2.3.0 -t airflow:latest .
	docker build -f ./dockerfile/dockerfile_airflow -t airflow:2.3.0 -t airflow:latest .
	docker build -f ./dockerfile/dockerfile_hadoop -t hadoop-service:3.2.3 -t hadoop-service:latest .
	docker build -f ./dockerfile/dockerfile_jupyter -t jupyter-spark:3.2.1 -t jupyter-spark:latest .
	docker build -f ./dockerfile/dockerfile_sparkbase -t spark-base:3.2.1 -t spark-base:latest .
	docker build -f ./dockerfile/dockerfile_sparkmaster -t spark-master:3.2.1 -t spark-master:latest .
	docker build -f ./dockerfile/dockerfile_sparkworker -t spark-worker:3.2.1 -t spark-worker:latest .
	
else

	if [[ "$(docker images -q airflow:latest 2> /dev/null)" == "" ]]; then
		docker build -f ./dockerfile/dockerfile_airflow -t airflow:2.3.0 -t airflow:latest .
	fi

	if [[ "$(docker images -q dbt-service:latest 2> /dev/null)" == "" ]]; then
		docker build -f ./dockerfile/dockerfile_dbt -t dbt-service:1.1.0 -t dbt-service:latest .
	fi

	if [[ "$(docker images -q hadoop-service:latest 2> /dev/null)" == "" ]]; then
		docker build -f ./dockerfile/dockerfile_hadoop -t hadoop-service:3.2.3 -t hadoop-service:latest .
	fi

	if [[ "$(docker images -q jupyter-spark:latest 2> /dev/null)" == "" ]]; then
		docker build -f ./dockerfile/dockerfile_jupyter -t jupyter-spark:3.2.1 -t jupyter-spark:latest .
	fi

	if [[ "$(docker images -q spark-base:latest 2> /dev/null)" == "" ]]; then
		docker build -f ./dockerfile/dockerfile_sparkbase -t spark-base:3.2.1 -t spark-base:latest .
	fi

	if [[ "$(docker images -q spark-master:latest 2> /dev/null)" == "" ]]; then
		docker build -f ./dockerfile/dockerfile_sparkmaster -t spark-master:3.2.1 -t spark-master:latest .
	fi

	if [[ "$(docker images -q spark-worker:latest 2> /dev/null)" == "" ]]; then
		docker build -f ./dockerfile/dockerfile_sparkworker -t spark-worker:3.2.1 -t spark-worker:latest .
	fi
fi
