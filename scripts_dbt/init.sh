#!/usr/bin/env bash


cd /dbt && rm -rf ./target/* && dbt compile
dbt docs generate && dbt docs serve --port 8081
