#!/usr/bin/env bash

# Setup DB Connection String
AIRFLOW__DATABASE__SQL_ALCHEMY_CONN="postgresql+psycopg2://${POSTGRES_USER}:${POSTGRES_PASSWORD}@${POSTGRES_HOST}:${POSTGRES_PORT}/${POSTGRES_DB}"
AIRFLOW__CORE__SQL_ALCHEMY_CONN="postgresql+psycopg2://${POSTGRES_USER}:${POSTGRES_PASSWORD}@${POSTGRES_HOST}:${POSTGRES_PORT}/${POSTGRES_DB}"
AIRFLOW__CELERY__RESULT_BACKEND="db+postgresql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@${POSTGRES_HOST}:${POSTGRES_PORT}/${POSTGRES_DB}"

export AIRFLOW__DATABASE__SQL_ALCHEMY_CONN
export AIRFLOW__CELERY__RESULT_BACKEND
export AIRFLOW__CORE__SQL_ALCHEMY_CONN

# AIRFLOW__WEBSERVER__SECRET_KEY="openssl rand -hex 30"
# export AIRFLOW__WEBSERVER__SECRET_KEY

AIRFLOW_CONN_DBT_POSTGRESQL_CONN="postgresql+psycopg2://${DBT_POSTGRES_USER}:${DBT_POSTGRES_PASSWORD}@${DBT_POSTGRES_HOST}:${POSTGRES_PORT}/${DBT_POSTGRES_DB}"
export AIRFLOW_CONN_DBT_POSTGRESQL_CONN

case "$1" in
  webserver)
    exec /entrypoint "$@"
    ;;
  worker|scheduler)
    # Give the webserver time to run initdb.
    sleep 10
    exec /entrypoint "$@"
    ;;
  flower)
    sleep 10
    exec /entrypoint "$@"
    ;;
  version)
    exec /entrypoint "$@"
    ;;
  *)
    # The command is something like bash, not an airflow subcommand. Just run it in the right environment.
	airflow connections add -conn_id 'dbt_postgres_instance_raw_data' --conn_uri $AIRFLOW_CONN_DBT_POSTGRESQL_CONN
    exec "$@"
    ;;
esac

