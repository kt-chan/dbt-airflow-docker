import os
import pandas as pd
import logging
import json

from airflow.utils.dates import days_ago
from datetime import datetime

from airflow import DAG, macros
from airflow.operators.bash_operator import BashOperator
from airflow.operators.python import PythonOperator
from airflow.hooks.hive_hooks import HiveServer2Hook
from sqlalchemy import *
from sqlalchemy.engine import create_engine
from sqlalchemy.schema import *


def jdbc_query(cmd=None, **kwargs):
    hiveConn = HiveServer2Hook(hiveserver2_conn_id='spark_thrift_default')
    try:
        hiveEngine = create_engine(hiveConn.get_uri().replace("hiveserver2", "hive")).connect()
        pd.read_sql_query(cmd,con=hiveEngine)
        hiveEngine.close()
    except sqlalchemy.exc.OperationalError as e:
        logging.error('Error occured while executing a query {}'.format(e.args))
        raise Exception("Error Returned!")
        return False
    
# [START default_args]
default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'start_date': datetime(2019, 1, 1),
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 1
}
# [END default_args]

# [START instantiate_dag]
load_initial_data_dag = DAG(
    '1_load_initial_data',
    default_args=default_args,
    schedule_interval = None,
)

t1 = PythonOperator(task_id='create_schema_source',
                      python_callable=jdbc_query,
                      op_kwargs={'cmd': "CREATE DATABASE IF NOT EXISTS source;"},
                      dag=load_initial_data_dag)

t999a = PythonOperator(task_id='drop_schema_sample',
                      python_callable=jdbc_query,
                      op_kwargs={'cmd': "DROP DATABASE IF EXISTS sample CASCADE;"},
                      dag=load_initial_data_dag)
                      
t999b = PythonOperator(task_id='create_schema_sample',
                      python_callable=jdbc_query,
                      op_kwargs={'cmd': "CREATE DATABASE IF NOT EXISTS sample;"},
                      dag=load_initial_data_dag)
                      
t2 = PythonOperator(task_id='drop_table_aisles',
                      python_callable=jdbc_query,
                      op_kwargs={'cmd': "DROP TABLE IF EXISTS source.aisles;"},
                      dag=load_initial_data_dag)

t3 = PythonOperator(task_id='create_aisles',
                      python_callable=jdbc_query,
                      op_kwargs={'cmd': """
                        create external table source.aisles (aisle_id integer, aisle varchar(100) ) 
                        ROW FORMAT DELIMITED 
                        FIELDS TERMINATED BY ',' 
                        STORED AS TEXTFILE 
                        LOCATION 'hdfs://hadoop-service:9000/data/aisles' 
                        tblproperties ('skip.header.line.count'='1')
                      """
                      },
                      dag=load_initial_data_dag)


t5 = PythonOperator(task_id='drop_table_departments',
                      python_callable=jdbc_query,
                      op_kwargs={'cmd': "DROP TABLE IF EXISTS source.departments;"},
                      dag=load_initial_data_dag)

t6 = PythonOperator(task_id='create_departments',
                      python_callable=jdbc_query,
                      op_kwargs={'cmd': """
                        create table if not exists source.departments (department_id integer, department varchar(100))
                        ROW FORMAT DELIMITED 
                        FIELDS TERMINATED BY ',' 
                        STORED AS TEXTFILE 
                        LOCATION 'hdfs://hadoop-service:9000/data/departments' 
                        tblproperties ('skip.header.line.count'='1')
                      """
                      },
                      dag=load_initial_data_dag)

t8 = PythonOperator(task_id='drop_table_products',
                      python_callable=jdbc_query,
                      op_kwargs={'cmd': "DROP TABLE IF EXISTS source.products;"},
                      dag=load_initial_data_dag)

t9 = PythonOperator(task_id='create_products',
                      python_callable=jdbc_query,
                      op_kwargs={'cmd': """
                        create table if not exists source.products (product_id integer, product_name varchar(200),	aisle_id integer, department_id integer)
                        ROW FORMAT DELIMITED 
                        FIELDS TERMINATED BY ',' 
                        STORED AS TEXTFILE 
                        LOCATION 'hdfs://hadoop-service:9000/data/products' 
                        tblproperties ('skip.header.line.count'='1')
                      """
                      },
                      dag=load_initial_data_dag)


t11 = PythonOperator(task_id='drop_table_orders',
                      python_callable=jdbc_query,
                      op_kwargs={'cmd': "DROP TABLE IF EXISTS source.orders;"},
                      dag=load_initial_data_dag)

t12 = PythonOperator(task_id='create_orders',
                      python_callable=jdbc_query,
                      op_kwargs={'cmd': """
                        create table if not exists source.orders ( order_id integer,user_id integer, eval_set varchar(10), order_number integer,order_dow integer,order_hour_of_day integer, days_since_prior_order real)
                        ROW FORMAT DELIMITED 
                        FIELDS TERMINATED BY ',' 
                        STORED AS TEXTFILE 
                        LOCATION 'hdfs://hadoop-service:9000/data/orders' 
                        TBLPROPERTIES ('external.table.purge'='true', 'skip.header.line.count'='1')
                      """
                      },
                      dag=load_initial_data_dag)

t14 = PythonOperator(task_id='drop_table_order_products',
                      python_callable=jdbc_query,
                      op_kwargs={'cmd': "DROP TABLE IF EXISTS source.order_products__prior;"},
                      dag=load_initial_data_dag)

t15 = PythonOperator(task_id='create_order_products',
                      python_callable=jdbc_query,
                      op_kwargs={'cmd': """
                        create table if not exists source.order_products(order_id integer, product_id integer, add_to_cart_order integer, reordered integer)
                        ROW FORMAT DELIMITED 
                        FIELDS TERMINATED BY ',' 
                        STORED AS TEXTFILE 
                        LOCATION 'hdfs://hadoop-service:9000/data/order_products__prior' 
                        tblproperties ('skip.header.line.count'='1')                        
                      """
                      },
                      dag=load_initial_data_dag)


t17 = PythonOperator(task_id='drop_table_order_products__new',
                      python_callable=jdbc_query,
                      op_kwargs={'cmd': "DROP TABLE IF EXISTS source.order_products__train;"},
                      dag=load_initial_data_dag)

t18 = PythonOperator(task_id='create_order_products__new',
                      python_callable=jdbc_query,
                      op_kwargs={'cmd': """
                        create table if not exists source.order_products_new(order_id integer, product_id integer, add_to_cart_order integer, reordered integer)
                        ROW FORMAT DELIMITED 
                        FIELDS TERMINATED BY ',' 
                        STORED AS TEXTFILE 
                        LOCATION 'hdfs://hadoop-service:9000/data/order_products__train' 
                        tblproperties ('skip.header.line.count'='1')      
                      """
                      },
                      dag=load_initial_data_dag)


t1 >> t2 >> t3 >> t999a >> t999b
t1 >> t5 >> t6  >> t999a >> t999b
t1 >> t8 >> t9  >> t999a >> t999b
t1 >> t11 >> t12 >> t999a >> t999b
t1 >> t14 >> t15  >> t999a >> t999b
t1 >> t17 >> t18  >> t999a >> t999b