etup:
	python -m venv .venv && . .venv/bin/activate && pip install -r requirements.txt && dbt deps

seed:
	dbt seed

build:
	dbt build --full-refresh

docs:
	dbt docs generate

lint:
	sqlfluff fix dbt --dialect duckdb --templater dbt || true
	sqlfluff lint dbt --dialect duckdb --templater dbt