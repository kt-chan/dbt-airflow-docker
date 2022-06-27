# Apache Airflow and DBT on Apache Spark with Hudi support, using Docker Compose
Stand-alone project that utilises public eCommerce data from Instacart to demonstrate how to schedule dbt models through Airflow.

For more Data & Analytics related reading, check https://analyticsmayhem.com

## Requirements 
* Install [Docker](https://www.docker.com/products/docker-desktop)
* Install [Docker Compose](https://github.com/docker/compose/releases v2.6) 
* Download the [Kaggle Instacart eCommerce dataset](https://www.kaggle.com/c/instacart-market-basket-analysis/data) 

## Dataset

The dataset for this competition is a relational set of files describing customers' orders over time. The goal of the competition is to predict which products will be in a user's next order. The dataset is anonymized and contains a sample of over 3 million grocery orders from more than 200,000 Instacart users. For each user, we provide between 4 and 100 of their orders, with the sequence of products purchased in each order. We also provide the week and hour of day the order was placed, and a relative measure of time between orders. For more information, see the blog post [https://tech.instacart.com/3-million-instacart-orders-open-sourced-d40d29ead6f2] accompanying its public release.

The user story for analytic example is available here:
1. https://rpubs.com/MohabDiab/482437
2. https://github.com/archd3sai/Instacart-Market-Basket-Analysis
3. https://asagar60.medium.com/instacart-market-basket-analysis-part-1-introduction-eda-b08fd8250502

## DBT with Spark and Hudi
https://github.com/apache/hudi/tree/master/hudi-examples/hudi-examples-dbt

## Setup 
* Clone the repository
* Run ./build.sh force
* Extract the "Kaggle Instacart eCommerce dataset" files to the new ./sample_data directory (files are needed as seed data)
* Run chmod +x *.sh
* Run start.sh

## Connections
* Airflow homepage: http://[hostname]:8080/home
* Jupyter notebook: http://[hostname]:8888/lab?token=welcome
* DBT homepage: http://[hostname]:8081/#!/overview
* Spark Master: http://[hostname]:8082/
* Spark Thrift: http://[hostname]:4040/jobs/

## How to ran the DAGs
Once everything is up and running, navigate to the Airflow UI (see connections above). You will be presented with the list of DAGs, all Off by default.

<img src="https://storage.googleapis.com/analyticsmayhem-blog-files/dbt-airflow-docker/dbt-dags-list.png" width="70%"></img>

You will need to run to execute them in correct order. 
- 1_load_initial_data: Load the raw Kaggle dataset
- 2_init_once_dbt_models: Perform some basic transformations (i.e. build an artificial date for the orders)
- 3_snapshot_dbt_models: Build the snapshot tables
- 4_daily_dbt_models: Schedule the daily models. The starting date is set on Jan 6th, 2019. This will force Ariflow to backfill all date for those dates. So leave that for last.

<img src="https://storage.googleapis.com/analyticsmayhem-blog-files/dbt-airflow-docker/dbt-dag-triggering.png" width="70%"></img>

If everything goes well, you should have the daily model execute successfully and see similar task durations as per below.

<img src="https://storage.googleapis.com/analyticsmayhem-blog-files/dbt-airflow-docker/dbt-task-duration-over-time.png" width="70%"></img>

Finally, within Adminer you can view the final models.
<img src="https://storage.googleapis.com/analyticsmayhem-blog-files/dbt-airflow-docker/dbt-adminer-view.png" width="70%"></img>

## Docker Compose Commands
* Enable the services: `docker-compose up` or `docker-compose up -d` (detatches the terminal from the services' log)
* Disable the services: `docker-compose down` Non-destructive operation.
* Delete the services: `docker-compose rm` Ddeletes all associated data. The database will be empty on next run.
* Re-build the services: `docker-compose build` Re-builds the containers based on the docker-compose.yml definition. Since only the Airflow service is based on local files, this is the only image that is re-build (useful if you apply changes on the `./scripts_airflow/init.sh` file. 

If you need to connect to the running containers, use `docker-compose ps` to view the running services.

<img src="https://storage.googleapis.com/analyticsmayhem-blog-files/dbt-airflow-docker/dbt-service-list.png" width="70%">

For example, to connect to the Airflow service, you can execute `docker exec -it dbt-airflow-docker_airflow_1 /bin/bash`. This will attach your terminal to the selected container and activate a bash terminal.

## Project Notes and Docker Volumes
Because the project directories (`./scripts_postgres`, `./sample_data`, `./dbt` and `./airflow`) are defined as volumes in `docker-compose.yml`, they are directly accessible from within the containers. This means:
* On Airflow startup the existing models are compiled as part of the initialisation script. If you make changes to the models, you need to re-compile them. Two options:
  * From the host machine navigate to `./dbt` and then `dbt compile`
  * Attach to the container by `docker exec -it dbt-airflow-docker_airflow_1 /bin/bash`. This will open a session directly in the container running Airflow. Then CD into `/dbt` and  `dbt compile`. In general attaching to the container, helps a lot in debugging.
* You can make changes to the dbt models from the host machine, `dbt compile` them and on the next DAG update they will be available (beware of changes that are major and require `--full-refresh`). It is suggested to connect to the container (`docker exec ...`) to run a full refresh of the models. Alternatively you can `docker-compose down && docker-compose rm && docker-compose up`. 
* The folder `./airflow/dags` stores the DAG files. Changes on them appear after a few seconds in the Airflow admin.
  * The `initialise_data.py` file contains the upfront data loading operation of the seed data.
  * The `dag.py` file contains all the handling of the DBT models. Keep aspect is the parsing of `manifest.json` which holdes the models' tree structure and tag details


Credit to the very helpful repository: https://github.com/puckel/docker-airflow
