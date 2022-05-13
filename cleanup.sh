#!/usr/bin/env bash
chmod +x cleanup.sh
chmod 777 -R airflow
docker-compose down --volumes --rmi all
