#!/usr/bin/env bash


cd /dbt 
rm -rf ./target/* 
dbt compile
dbt docs generate 
dbt docs serve --port 8081 & 
dbt-rpc serve --port 8580 & 

# Wait for any process to exit
wait -n
  
# Exit with status of process that exited first
exit $?