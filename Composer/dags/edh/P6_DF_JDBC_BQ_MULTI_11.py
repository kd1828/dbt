# Author: Pratul Singh
# Version: 1.0
# Date of version: 18/01/2022

# *******************************************************************
#
# This Dag is to load EDH multiple complete load type SQL Server table data into BQ
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
pei_id = 'P6_DF_JDBC_BQ_MULTI_11'
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
        "P6_DF_JDBC_BQ_MULTI_11",
        schedule_interval=None,  # every day at 0-23 run every 6 hrs:00 UTC
        default_args=default_args) as dag:
    jdbc_bq_multi_11 = DataFlowJavaOperator(
        # task_id=pipeline_id.replace("_", "-").lower(),
        task_id="jdbc_bq_multi_11",
        poll_sleep=5,
        jar=f"gs://{dataflow_executable_bucket_name}/JAR/JDBC_BQ/EL.JDBC.BQ-bundled-1.0-SNAPSHOT.jar",
        options={
            "SQLServerServerName": sqlServerHost,
            "SQLServerDatabase": "EDH",
            "sqlServerUsernameSecretKey": "edh-ingestion-username",
            "sqlServerPasswordSecretKey": "edh-ingestion-password",
            "bucketName": f"peics-ds-insite-global-{environment_name}",
            "BQDataSet": "lnd_insite",
            "BQTable": "RPT_QM_RFS_Prep,RPT_CX_PPP_Detail_Prep,RPT_PR_KPIs_Prep,RPT_WM_KPIs_Prep,RPT_RO_Risks_Prep,RPT_PP_Project_Period_Prep,RPT_CX_CPRS_Prep,RPT_CX_Notices_Upstream_Prep,RPT_CF_Turnover_Forecast_20Perc_prep,RPT_CF_Task_Project_Milestones_Prep,RPT_PO_Period_Prep,RPT_CX_Notices_Downstream_Prep,RPT_CF_Turnover_Accrual_Overall_Prep,RPT_CX_BCHG_Prep,RPT_RO_Risks_Hit_Map_Prep,RPT_HS_Learning_Development_Prep,RPT_SP_Innovations_Prep,RPT_SU_Performance_Prep,RPT_RO_Risk_2,RPT_KPI_Notes_Prep,RPT_HS_Audit_Action_Prep,RPT_CX_TAIP_Prep,RPT_CX_TAIP_Prep_RN,RPT_RO_Risk_1,RPT_RFN_National_Regional_Mapping,RPT_CF_Commitment_To_Spend_Prep_RN,RPT_CP_Bank_Guarantees_Prep,RPT_CX_HCLM_Prep,RPT_CX_HNLC_Prep",
            "tableName": "DM_Projects_PID.RPT_QM_RFS_Prep,DM_Projects_PID.RPT_CX_PPP_Detail_Prep,DM_Projects_PID.RPT_PR_KPIs_Prep,DM_Projects_PID.RPT_WM_KPIs_Prep,DM_Projects_PID.RPT_RO_Risks_Prep,DM_Projects_PID.RPT_PP_Project_Period_Prep,DM_Projects_PID.RPT_CX_CPRS_Prep,DM_Projects_PID.RPT_CX_Notices_Upstream_Prep,DM_Projects_PID.RPT_CF_Turnover_Forecast_20Perc_prep,DM_Projects_PID.RPT_CF_Task_Project_Milestones_Prep,DM_Projects_PID.RPT_PO_Period_Prep,DM_Projects_PID.RPT_CX_Notices_Downstream_Prep,DM_Projects_PID.RPT_CF_Turnover_Accrual_Overall_Prep,DM_Projects_PID.RPT_CX_BCHG_Prep,DM_Projects_PID.RPT_RO_Risks_Hit_Map_Prep,DM_Projects_PID.RPT_HS_Learning_Development_Prep,DM_Projects_PID.RPT_SP_Innovations_Prep,DM_Projects_PID.RPT_SU_Performance_Prep,TEMP_ETL.RPT_RO_Risk_2,DM_Projects_PID.RPT_KPI_Notes_Prep,DM_Projects_PID.RPT_HS_Audit_Action_Prep,DM_Projects_PID.RPT_CX_TAIP_Prep,DM_Projects_PID.RPT_CX_TAIP_Prep_RN,TEMP_ETL.RPT_RO_Risk_1,DM_Projects_PID.RPT_RFN_National_Regional_Mapping,DM_Projects_PID.RPT_CF_Commitment_To_Spend_Prep_RN,DM_Projects_PID.RPT_CP_Bank_Guarantees_Prep,DM_Projects_PID.RPT_CX_HCLM_Prep,DM_Projects_PID.RPT_CX_HNLC_Prep",
            "controlLocation" : "schema",
            "loadType": "Complete",
            "loadTable": "Multi",
            "etlJobId": pei_run_id,
            "etlParentJobId": pei_run_id_parent
        },
    )

dag >> jdbc_bq_multi_11