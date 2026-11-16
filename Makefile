include .env
export

export PROJECT_ROOT=$(shell pwd)

env-up:
	@docker compose up -d todoapp-postgres

env-down:
	@docker compose down todoapp-postgres

env-cleanup:
	@printf "Are you sure you want to clear all volume files!Risk of data loss! [y/N]: " ans; \
	read ans; \
	if [ "$$ans" = "y" ]; then \
	  docker compose down todoapp-postgres && \
	  rm -rf out/pgdata && \
	  echo "Environment files have been cleaned."; \
	else \
	  echo "Environment clearing cancelled. "; \
	fi

migrate-create:
	@if [ -z "$(seq)" ]; then \
  		echo "Required parameter is missing: seq (make migrate-create seq=init)"; \
  		exit 1; \
  	fi; \
	docker compose run --rm todoapp-postgres-migrate \
		create \
		-ext sql \
		-dir /migrations \
		-seq "$(seq)"

migrate-up:
	@$(MAKE) migrate-action action=up

migrate-down:
	@$(MAKE) migrate-action action=down

migrate-action:
	@if [ -z "$(action)" ]; then \
      		echo "Required parameter is missing: action (make migrate-action action=down)"; \
      		exit 1; \
      	fi; \
	docker compose run --rm todoapp-postgres-migrate \
    		-path /migrations \
    		-database "postgres://${POSTGRES_USER}:${POSTGRES_PASSWORD}@todoapp-postgres:5432/${POSTGRES_DB}?sslmode=disable" \
    		$(action)

env-port-forward:
	@docker compose up -d port-forwarder

env-port-close:
	@docker compose down port-forwarder

todoapp-run:
	@go run cmd/main.go