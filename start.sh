#!/usr/bin/env bash
docker-compose build
docker-compose up dbt-service -d
docker-compose up airflow-init -d
docker-compose up -d

