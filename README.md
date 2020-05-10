# Apache Airflow and DBT using Docker Compose
Stand-alone project that utilises public eCommerce data from Instacart to demonstrate how to schedule dbt models through Airflow.

For more Data & Analytics related reading, check https://analyticsmayhem.com

## Requirements 
* Install [Docker](https://www.docker.com/products/docker-desktop)
* Install [Docker Compose](https://docs.docker.com/compose/install/)
* Download the [Kaggle Instacart eCommerce dataset](https://www.kaggle.com/c/instacart-market-basket-analysis/data) 

## Setup 
* Clone the repository
* Extract the CSV files within ./sample_data directory (files are needed as seed data)

Change directory within the repository and run `docker-compose up`. This will perform the following:
* Based on the definition of [`docker-compose.yml`](https://github.com/konosp/dbt-airflow-docker-compose/blob/master/docker-compose.yml) will download the necessary images to run the project. This includes the following services:
* * postgres-airflow: DB for Airflow to connect and store task execution information
* * postgres-dbt: DB for the DBT seed data and SQL models to be stored
* * airflow: Python-based image to execute Airflow scheduler and webserver
* * adminer: a lightweight DB client

## Connections
* Adminer UI: [http://localhost:8080](http://localhost:8080/?pgsql=postgres-dbt&username=dbtuser&db=dbtdb&ns=dbt) Credentials as defined at [`docker-compose.yml`](https://github.com/konosp/dbt-airflow-docker-compose/blob/master/docker-compose.yml)
* Airflow UI: http://localhost:8000

## How to ran the DAGs
TODO

## Docker Compose Commands
* Enable the services: `docker-compose up` or `docker-compose up -d` (detatches the terminal from the services' log)
* Disable the services: `docker-compose down` Non-destructive operation.
* Delete the services: `docker-compose rm` Ddeletes all associated data. The database will be empty on next run.
* Re-build the services: `docker-compose build` Re-builds the containers based on the docker-compose.yml definition. Since only the Airflow service is based on local files, this is the only image that is re-build (useful if you apply changes on the `./scripts_airflow/init.sh` file. 

## Project Notes and Docker Volumes
Because the project directories (`./scripts_postgres`, `./sample_data`, `./dbt` and `./airflow`) are defined as volumes in `docker-compose.yml`, they are directly accessible from within the containers. This means:
* On Airflow startup the existing models are compiled as part of the initialisation script. If you make changes to the models, you need to re-compile them. Two options:
* * From the host machine navigate to `./dbt` and then `dbt compile`
* * Attach to the container by `docker exec -it dbt-airflow-docker_airflow_1 /bin/bash`. This will open a session directly in the container running Airflow. Then CD into `/dbt` and  `dbt compile`. In general attaching to the container, helps a lot in debugging.
* You can make changes to the dbt models from the host machine, `dbt compile` them and on the next DAG update they will be available (beware of changes that are major and require `--full-refresh`). It is suggested to connect to the container (`docker exec ...`) to run a full refresh of the models. Alternatively you can `docker-compose down && docker-compose rm && docker-compose up`. 
* The folder `./airflow/dags` stores the DAG files. Changes on them appear after a few seconds in the Airflow admin.
* * The `initialise_data.py` file contains the upfront data loading operation of the seed data.
* * The `dag.py` file contains all the handling of the DBT models. Keep aspect is the parsing of `manifest.json` which holdes the models' tree structure and tag details


Credit to the very helpful repository: https://github.com/puckel/docker-airflow
