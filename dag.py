from airflow import DAG
from airflow.operators.dummy import DummyOperator
from airflow.providers.google.cloud.operators.dataflow import DataflowStartPythonJobOperator
from airflow.utils.dates import days_ago

# Define default arguments for the DAG
default_args = {
    'owner': 'airflow',
    'start_date': days_ago(1),
    'retries': 1,
}

# Instantiate the DAG
with DAG(
    dag_id='beam_dataflow_pipeline_with_params',
    default_args=default_args,
    schedule_interval=None,  # Can set to an appropriate interval
    catchup=False,
    description='Run Apache Beam pipeline on Dataflow with parameters',
) as dag:

    # Start Dummy Task
    start = DummyOperator(
        task_id='start'
    )

    # Define your parameters to pass to the Beam pipeline
    pipeline_params = {
        'input': 'gs://your-bucket/input-data',  # Example input parameter
        'output': 'gs://your-bucket/output-data',  # Example output parameter
        'max_num_workers': '5',  # Example parameter for max workers
        # Add any additional custom pipeline parameters here
    }

    # Task to run Apache Beam Python code on Google Dataflow with parameters
    run_beam_pipeline = DataflowStartPythonJobOperator(
        task_id='run_beam_pipeline',
        py_file='gs://your-bucket/path-to-your-python-file.py',  # Update with your GCS path
        job_name='beam-pipeline-job',
        options=pipeline_params,  # Pass the parameters here
        dataflow_default_options={
            'project': 'your-gcp-project-id',
            'region': 'us-central1',  # Change to your region
            'runner': 'DataflowRunner',
            'temp_location': 'gs://your-bucket/temp',  # Update to your GCS bucket
            'staging_location': 'gs://your-bucket/staging',  # Update to your GCS bucket
        },
    )

    # End Dummy Task
    end = DummyOperator(
        task_id='end'
    )

    # Task Dependencies
    start >> run_beam_pipeline >> end