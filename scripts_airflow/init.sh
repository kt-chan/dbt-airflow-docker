#!/usr/bin/env bash

# Setup DB Connection String
AIRFLOW__CORE__SQL_ALCHEMY_CONN="postgresql+psycopg2://${POSTGRES_USER}:${POSTGRES_PASSWORD}@${POSTGRES_HOST}:${POSTGRES_PORT}/${POSTGRES_DB}"
AIRFLOW__CELERY__RESULT_BACKEND="db+postgresql://${POSTGRES_HOST}:${POSTGRES_PORT}/${POSTGRES_DB}?user=${POSTGRES_USER}&password=${POSTGRES_PASSWORD}"

export AIRFLOW__CORE__SQL_ALCHEMY_CONN
export AIRFLOW__CELERY__RESULT_BACKEND


# AIRFLOW__WEBSERVER__SECRET_KEY="openssl rand -hex 30"
# export AIRFLOW__WEBSERVER__SECRET_KEY

DBT_POSTGRESQL_CONN="postgresql+psycopg2://${DBT_POSTGRES_USER}:${DBT_POSTGRES_PASSWORD}@${DBT_POSTGRES_HOST}:${POSTGRES_PORT}/${DBT_POSTGRES_DB}"
export DBT_POSTGRESQL_CONN

## test
sleep 10

ls -al /airflow
ls -al /dbt

airflow connections --add --conn_id 'dbt_postgres_instance_raw_data' --conn_uri $DBT_POSTGRESQL_CONN

