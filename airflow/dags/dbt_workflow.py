from airflow import DAG, macros, AirflowException
from airflow.operators.bash_operator import BashOperator
from airflow.operators.python_operator import PythonOperator
from airflow.contrib.hooks.ssh_hook import SSHHook
from airflow.utils.dates import days_ago
from datetime import datetime


# For Logging on debug
import logging

# Parse nodes
import json
JSON_MANIFEST_DBT = '/dbt/target/manifest.json'
PARENT_MAP = 'parent_map'

def ssh_run(cmd=None, **kwargs):
    ssh = SSHHook(ssh_conn_id='dbt_ssh_conn')
    ssh_client = None
    try:
        ssh_client = ssh.get_conn()
        ssh_client.load_system_host_keys()
        stdin, stdout, stderr = ssh_client.exec_command(cmd)
        logging.info("stdout ------>"+str(stdout.readlines()))
        logging.info("Error--------->"+str(stderr.readlines()))
        if (stdout.channel.recv_exit_status())!= 0:
            logging.info("Error Return code not Zero:"+ 
            str(stdout.channel.recv_exit_status()))
            raise Exception("Error Returned!")
            return False
        else:
            return True
            
    finally:
        if ssh_client:
            ssh_client.close()    

def sanitise_node_names(value):
        segments = value.split('.')
        if (segments[0] == 'model'):
                return value.split('.')[-1]

def get_node_structure():
    with open(JSON_MANIFEST_DBT) as json_data:
        data = json.load(json_data)
    ancestors_data = data[PARENT_MAP]
    tree = {}
    for node in ancestors_data:
            ancestors = list(set(ancestors_data[node]))
            ancestors_2 = []
            for ancestor in ancestors:
                if (sanitise_node_names(ancestor) is not None):
                    ancestors_2.append(sanitise_node_names(ancestor))
                    
            clean_node_name = sanitise_node_names(node)
            if (clean_node_name is not None) and (ancestors_2 is not None):
                    tree[clean_node_name] = {}
                    tree[clean_node_name]['ancestors'] = ancestors_2
                    tree[clean_node_name]['tags'] = data['nodes'][node]['tags']
    
    return tree


# [START default_args]
default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'start_date':   datetime(2020, 1, 1),
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 1
}
# [END default_args]

# [START instantiate_dag]
daily_dag = DAG(
    '4_daily_dbt_models',
    default_args=default_args,
    description='Managing dbt data pipeline',
    schedule_interval = '@daily',
)

snapshot_dag = DAG(
    '3_snapshot_dbt_models',
    default_args=default_args,
    description='Managing dbt data pipeline',
    schedule_interval = None,
)

init_once_dag = DAG(
    '2_init_once_dbt_models',
    default_args=default_args,
    description='Managing dbt data pipeline',
    schedule_interval = None,
)

dbt_refresh_dag = DAG(
    '999_dbt_refresh_dag',
    default_args=default_args,
    description='Managing dbt compile / docs ',
    schedule_interval = None,
)

dbt_refresh_compile = PythonOperator(
            task_id= 'dbt_refresh_compile',
            python_callable=ssh_run,
            op_kwargs={'cmd': 'cd /dbt && dbt compile '},
            dag=dbt_refresh_dag,
            depends_on_past = True
        )
dbt_refresh_run = PythonOperator(
            task_id= 'dbt_refresh_run',
            python_callable=ssh_run,
            op_kwargs={'cmd': 'cd /dbt && dbt run '},
            dag=dbt_refresh_dag,
            depends_on_past = True
        )
dbt_refresh_test = PythonOperator(
            task_id= 'dbt_refresh_test',
            python_callable=ssh_run,
            op_kwargs={'cmd': 'cd /dbt && dbt test '},
            dag=dbt_refresh_dag,
            depends_on_past = True
        )
dbt_refresh_doc = PythonOperator(
            task_id= 'dbt_refresh_doc',
            python_callable=ssh_run,
            op_kwargs={'cmd': 'cd /dbt && dbt docs generate '},
            dag=dbt_refresh_dag,
            depends_on_past = True
        )

dbt_refresh_compile >> dbt_refresh_run >> dbt_refresh_test >> dbt_refresh_doc
        
data_operators = {}
# [END instantiate_dag]

nodes = get_node_structure()

for node in nodes:
    if ('daily' in nodes[node]['tags']):
        date_end = "{{ ds }}"
        date_start = "{{ yesterday_ds }}"
        bsh_cmd = 'cd /dbt && dbt run --models {nodeName} --vars \'{{"start_date":"{start_date}", "end_date":"{end_date}"}}\' '.format(nodeName = node, start_date = date_start, end_date = date_end)
        tmp_operator = PythonOperator(
            task_id= node,
            python_callable=ssh_run,
            op_kwargs={'cmd': bsh_cmd},
            dag=daily_dag,
            depends_on_past = True
        )
        data_operators[node] = tmp_operator

    elif ('snapshot' in nodes[node]['tags']):
        bsh_cmd = 'cd /dbt && dbt run --models {nodeName} '.format(nodeName = node)
        tmp_operator = PythonOperator(
            task_id= node,
            python_callable=ssh_run,
            op_kwargs={'cmd': bsh_cmd},
            dag=snapshot_dag,
            depends_on_past = True
        )
        data_operators[node] = tmp_operator

    elif ('init-once' in nodes[node]['tags']):
        date_end = "{{ ds }}"
        date_start = "{{ yesterday_ds }}"
        bsh_cmd = 'cd /dbt && dbt run --models {nodeName} '.format(nodeName = node)
        tmp_operator = PythonOperator(
            task_id= node,
            python_callable=ssh_run,
            op_kwargs={'cmd': bsh_cmd},
            dag=init_once_dag,
            depends_on_past = True
        )
        data_operators[node] = tmp_operator

# Parse nodes and assign operator dependencies
for node in nodes:
    for parent in nodes[node]['ancestors']:
        if nodes[node]['tags'] == nodes[parent]['tags']:
            data_operators[parent] >> data_operators[node]

