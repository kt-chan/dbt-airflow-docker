#!/usr/bin/env bash
chmod +x cleanup.sh
chmod 777 -R airflow/logs
chmod 777 -R airflow/dags
chmod 777 -R airflow/plugins
docker-compose down --volumes --rmi all
