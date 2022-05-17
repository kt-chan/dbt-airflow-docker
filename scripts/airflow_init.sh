#!/usr/bin/env bash

su airflow -c "airflow connections add 'dbt_postgres_instance_raw_data' --conn-uri $AIRFLOW_CONN_DBT_POSTGRESQL_CONN"
