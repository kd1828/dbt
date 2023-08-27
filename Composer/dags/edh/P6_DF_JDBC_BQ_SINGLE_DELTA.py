# Author: Kevin Dang
# Version: 1.0
# Date of version: 09/02/2022

# *******************************************************************
#
# This Dag is to load EDH single delta load type SQL Server table data into BQ
# *******************************************************************

from airflow import DAG
from airflow.contrib.operators.bigquery_operator import BigQueryOperator
from airflow.contrib.operators.bigquery_operator import BigQueryCreateEmptyTableOperator
from airflow.contrib.operators.gcs_list_operator import GoogleCloudStorageListOperator
from airflow.contrib.sensors.gcs_sensor import GoogleCloudStoragePrefixSensor
from airflow.operators.dagrun_operator import TriggerDagRunOperator
from airflow.operators.python_operator import PythonOperator
from airflow.operators.dummy_operator import DummyOperator
import datetime

import P6.xcom_utility_v2 as xcom_utility_v2
import random
from airflow import models
import json
from google.cloud import storage
from airflow.utils.db import provide_session
from airflow.models import XCom
from airflow.contrib.operators.gcs_to_bq import GoogleCloudStorageToBigQueryOperator
from airflow.contrib.operators.gcs_to_gcs import GoogleCloudStorageToGoogleCloudStorageOperator
from airflow.contrib.operators.bigquery_check_operator import BigQueryCheckOperator
from airflow.providers.google.cloud.operators.bigquery import BigQueryInsertJobOperator

from airflow.contrib.operators.dataflow_operator import DataFlowJavaOperator
from airflow.utils.dates import days_ago

# ------------------------------------------------------------------------------------------------------------------------
# Data sinks:
# Google Big Query
# Google Cloud Storage
# ------------------------------------------------------------------------------------------------------------------------

yesterday = datetime.datetime.combine(datetime.datetime.today() - datetime.timedelta(1), datetime.datetime.min.time())

# Define dag variables

pipeline_id_parent = 'P6_DF_JDBC_BQ'
pei_id = 'P6_DF_JDBC_BQ_SINGLE_DELTA'
run_id = "{{ run_id }}"

pei_run_id = ("{pipe}-{n}".format(pipe=pei_id, n=run_id))
pei_run_id_parent = ("{pipe}-{n}".format(pipe=pipeline_id_parent,
                                         n="{{ti.xcom_pull(dag_id='P6_DF_Master_V4',task_ids='push_numb',key='P6_DF_Master_V4',include_prior_dates=True)}}"))

status_bucket = models.Variable.get("bucket_dag")
status_folder = models.Variable.get("status_folder")
sqlServerHost = models.Variable.get("sqlServerHost")
project_id = models.Variable.get("project_id")
gce_zone = models.Variable.get("gce_zone")
gce_region = models.Variable.get("gce_region")
environment_name = models.Variable.get("environment_name")
dataflow_executable_bucket_name = models.Variable.get("dataflow_executable_bucket_name")
dataflow_service_account = models.Variable.get("dataflow_service_account")
zone = models.Variable.get("zone")
subnetwork = models.Variable.get("subnetworkedh")

default_args = {
    'start_date': yesterday,
    "dataflow_default_options": {
        "project": project_id,
        "region": gce_region,
        "tempLocation": f'gs://peics-ds-ingestion-temp-au-{environment_name}/temp/',
        "subnetwork": subnetwork,
        "serviceAccount": dataflow_service_account,
        "usePublicIps": "false",
        "workerZone": zone
    },
}

# Define a DAG (directed acyclic graph) of tasks.
# Any task you create within the context manager is automatically added to the
# DAG object.
with models.DAG(
        "P6_DF_JDBC_BQ_SINGLE_DELTA",
        schedule_interval=None,  # every day at 0-23 run every 6 hrs:00 UTC
        default_args=default_args) as dag:
    jdbc_bq_single_delta = DataFlowJavaOperator(
        # task_id=pipeline_id.replace("_", "-").lower(),
        task_id="jdbc_bq_single_delta",
        poll_sleep=5,
        jar=f"gs://{dataflow_executable_bucket_name}/JAR/JDBC_BQ/EL.JDBC.BQ-bundled-1.0-SNAPSHOT.jar",
        options={
            "SQLServerServerName": sqlServerHost,
            "SQLServerDatabase": "EDH",
            "sqlServerUsernameSecretKey": "edh-ingestion-username",
            "sqlServerPasswordSecretKey": "edh-ingestion-password",
            "bucketName": f"peics-ds-insite-global-{environment_name}",
            "BQDataSet": "pei_insite_landing",
            "BQTable": "**************RPT_CF_Task_Project_Financial_Prep*******",
            "tableName": "************DM_Projects_PID.RPT_CF_Task_Project_Financial_Prep********",
            "controlLocation": "schema",
            "targetLocation": "inbound",
            "dataSourceType": "Table",
            "loadType": "Delta",
            "loadTable": "Single",
            "deltaType": "ByMonth",
            "runType": "Single",
            "deltaNumber": "3",
            "deltaField": "Month_SKey",
            "etlJobId": pei_run_id,
            "etlParentJobId": pei_run_id_parent
        },
    )

dag >> jdbc_bq_single_delta