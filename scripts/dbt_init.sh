#!/usr/bin/env bash

# Enable ssh server
/etc/init.d/ssh restart


cd /dbt 

# dbt compile
# dbt docs generate 
dbt docs serve --port 8081 & 

## # Wait for any process to exit
## wait -n
##   
## # Exit with status of process that exited first
## exit $?

## testing for log output
tail -f /dbt/logs/dbt.log
