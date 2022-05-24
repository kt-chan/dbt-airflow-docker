#!/usr/bin/env bash
docker-compose build
docker-compose up airflow-init -d
docker-compose up spark-master -d
docker-compose up -d

