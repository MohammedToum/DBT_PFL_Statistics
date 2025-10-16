from datetime import datetime
from airflow import DAG
from airflow.operators.bash import BashOperator
import os

# Configure via Airflow Variables:
#  - SEASONS_CSV_DIR: absolute path to your season CSVs (e.g., repo dbt/seeds/split_files)
#  - DB_PATH: absolute path to DuckDB file (e.g., .../warehouse/plt.duckdb)

SEASONS = [str(y) for y in range(2018, datetime.now().year + 1)]

default_args = {"owner": "data-eng", "depends_on_past": False}

with DAG(
    dag_id="ingest_premier_league_seasons",
    start_date=datetime(2024, 1, 1),
    schedule=None,
    catchup=False,
    default_args=default_args,
    description="Load one season at a time into main.raw_transfers, then run dbt",
) as dag:

    for season in SEASONS:
        csv = "{{ var.value.SEASONS_CSV_DIR }}/premier_league_" + season + ".csv"
        load = BashOperator(
            task_id=f"load_{season}",
            bash_command=(
                "duckdb {{ var.value.DB_PATH }} "
                "\"create schema if not exists main; "
                "create table if not exists main.raw_transfers as "
                "select * from read_csv_auto('" + csv + "', header=true) where 1=0; "
                "insert into main.raw_transfers select * from read_csv_auto('" + csv + "', header=true);\""
            ),
        )

        dbt_build = BashOperator(
            task_id=f"dbt_build_{season}",
            bash_command=(
                "cd $AIRFLOW_HOME/.. && "  # adjust to repo path if checked out on worker
                "dbt deps && dbt build --select stg_transfers+"
            ),
        )

        load >> dbt_build