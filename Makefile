# Makefile for DBT_PFL_Statistics project

# Default target
.DEFAULT_GOAL := help

.PHONY: help
help: ## Show available targets
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

# ------------------------
# Dev tooling
# ------------------------

.PHONY: install
install: ## Sync venv with requirements.txt
	pip-sync requirements.txt

.PHONY: add
add: ## Add a new package via pip-tools (usage: make add pkg="requests")
	@if [ -z "$(pkg)" ]; then \
		echo "❌ Usage: make add pkg=package_name"; \
		exit 1; \
	fi
	@echo "➡️ Adding package: $(pkg)"
	@echo "$(pkg)" >> requirements.in
	pip-compile requirements.in -o requirements.txt
	pip-sync requirements.txt

.PHONY: lint
lint: ## Run all pre-commit hooks on all files
	pre-commit run --all-files

.PHONY: secrets-baseline
secrets-baseline: ## Regenerate detect-secrets baseline
	detect-secrets scan --all-files \
	  --exclude-files '(dbt_packages|target|\.venv|node_modules|\.git)/' \
	  > .secrets.baseline
	git add .secrets.baseline
	@echo "✅ Secrets baseline updated and staged."

# ------------------------
# dbt commands
# ------------------------

.PHONY: dbt-build
dbt-build: ## Run dbt build (models + seeds + tests)
	dbt build --profiles-dir ~/.dbt --target dev

.PHONY: dbt-test
dbt-test: ## Run dbt tests only
	dbt test --profiles-dir ~/.dbt --target dev

.PHONY: dbt-run
dbt-run: ## Run dbt run only (skip tests)
	dbt run --profiles-dir ~/.dbt --target dev

.PHONY: dbt-clean
dbt-clean: ## Clean dbt artifacts (target, logs)
	dbt clean
