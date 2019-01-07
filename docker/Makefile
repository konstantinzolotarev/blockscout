SYSTEM = $(shell uname -s)
HOST = host.docker.internal
DOCKER_IMAGE = blockscout_prod
PG_CONTAINER_NAME = postgres
PG_CONTAINER_IMAGE = postgres:10.4
THIS_FILE = $(lastword $(MAKEFILE_LIST))
APP_NAME ?= blockscout
APP_VSN ?= `grep 'version:' ../rel/config.exs | cut -d '"' -f2`
BUILD ?= `git rev-parse --short HEAD`

ifeq ($(SYSTEM), Linux)
	HOST=localhost
endif

DB_URL = postgresql://postgres:@$(HOST):5432/explorer?ssl=false
BLOCKSCOUT_CONTAINER_PARAMS = -e 'MIX_ENV=prod' \
							   -e 'DATABASE_URL=$(DB_URL)' \
							   -e 'PORT=4000'
ifeq ($(SYSTEM), Linux)
	BLOCKSCOUT_CONTAINER_PARAMS += --network=host
endif
ifdef ETHEREUM_JSONRPC_VARIANT
	BLOCKSCOUT_CONTAINER_PARAMS += -e 'ETHEREUM_JSONRPC_VARIANT=$(ETHEREUM_JSONRPC_VARIANT)'
endif
ifdef ETHEREUM_JSONRPC_HTTP_URL
	BLOCKSCOUT_CONTAINER_PARAMS += -e 'ETHEREUM_JSONRPC_HTTP_URL=$(ETHEREUM_JSONRPC_HTTP_URL)'
endif
ifdef ETHEREUM_JSONRPC_WS_URL
	BLOCKSCOUT_CONTAINER_PARAMS += -e 'ETHEREUM_JSONRPC_WS_URL=$(ETHEREUM_JSONRPC_WS_URL)'
endif
ifdef ETHEREUM_JSONRPC_TRACE_URL
	BLOCKSCOUT_CONTAINER_PARAMS += -e 'ETHEREUM_JSONRPC_TRACE_URL=$(ETHEREUM_JSONRPC_TRACE_URL)'
endif
ifdef COIN
	BLOCKSCOUT_CONTAINER_PARAMS += -e 'COIN=$(COIN)'
endif
ifdef LOGO
	BLOCKSCOUT_CONTAINER_PARAMS += -e 'LOGO=$(LOGO)'
endif
ifdef NETWORK
	BLOCKSCOUT_CONTAINER_PARAMS += -e 'NETWORK=$(NETWORK)'
endif
ifdef SUBNETWORK
	BLOCKSCOUT_CONTAINER_PARAMS += -e 'SUBNETWORK=$(SUBNETWORK)'
endif
ifdef NETWORK_ICON
	BLOCKSCOUT_CONTAINER_PARAMS += -e 'NETWORK_ICON=$(NETWORK_ICON)'
endif
ifdef NETWORK_PATH
	BLOCKSCOUT_CONTAINER_PARAMS += -e 'NETWORK_PATH=$(NETWORK_PATH)'
endif

HAS_BLOCKSCOUT_IMAGE := $(shell docker images | grep ${DOCKER_IMAGE}:$(APP_VSN)-$(BUILD))
build: postgres
	@echo "==> Checking for blockscout image $(DOCKER_IMAGE)"
ifdef HAS_BLOCKSCOUT_IMAGE
	@echo "==> Image exist. Using $(DOCKER_IMAGE)"
else
	@echo "==> No image found trying to build one..."
	@docker build \
			--build-arg APP_NAME=$(APP_NAME) \
			--build-arg APP_VSN=$(APP_VSN) \
			--build-arg DATABASE_URL=$(DATABASE_URL) \
			-f ./Dockerfile \
			-t $(DOCKER_IMAGE):$(APP_VSN)-$(BUILD) \
			-t $(DOCKER_IMAGE):latest ../
endif

# migrate: build
# 	@echo "==> Running migrations"
# 	@docker run --rm \
# 			$(BLOCKSCOUT_CONTAINER_PARAMS) \
# 			$(DOCKER_IMAGE) /bin/sh -c "echo $$MIX_ENV && mix do ecto.drop --force, ecto.create, ecto.migrate"


PG_EXIST := $(shell docker ps -a | grep ${PG_CONTAINER_NAME})
PG_STARTED := $(shell docker ps | grep ${PG_CONTAINER_NAME})
postgres:
ifdef PG_EXIST
	@echo "==> Checking PostrgeSQL container"
ifdef PG_STARTED
	@echo "==> PostgreSQL Already started"
else
	@echo "==> Starting PostgreSQL container"
	@docker start $(PG_CONTAINER_NAME)
endif
else
	@echo "==> Creating new PostgreSQL container"
	@docker run -d --name $(PG_CONTAINER_NAME) \
					-e POSTGRES_PASSWORD="" \
					-e POSTGRES_USER="postgres" \
					-p 5432:5432 \
					$(PG_CONTAINER_IMAGE)
	@sleep 1
	# @$(MAKE) -f $(THIS_FILE) migrate
endif

start: build 
	@echo "==> Starting blockscout"
	@echo $(BLOCKSCOUT_CONTAINER_PARAMS)
	@docker run --rm -it \
					-e ECTO_USE_SSL=false \
					$(BLOCKSCOUT_CONTAINER_PARAMS) \
					-p 4000:4000 \
					$(DOCKER_IMAGE):$(APP_VSN)-$(BUILD)

run: start

run-debug: build
	@echo "==> Starting blockscout"
	@echo $(BLOCKSCOUT_CONTAINER_PARAMS)
	@docker run --rm -it \
					-e ECTO_USE_SSL=false \
					$(BLOCKSCOUT_CONTAINER_PARAMS) \
					-p 4000:4000 \
					$(DOCKER_IMAGE):$(APP_VSN)-$(BUILD) /bin/bash

.PHONY: build \
		migrate \
		start \
		postgres \
		run \
		run-debug