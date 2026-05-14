BIN_DIR := $(PWD)/bin
APP_NAME := ai-booking-flow
BUILD_DIR := $(PWD)/build
DB_URL ?= postgres://postgres:postgres@localhost:5432/booking?sslmode=disable

.PHONY: tools install-tools clean-tools \
        build run dev test lint fmt \
        proto generate-mocks \
        migrate-up migrate-down migrate-create \
        docker-build docker-up docker-up-full docker-down docker-logs

tools: install-tools

install-tools: bin/air bin/protoc-gen-go bin/protoc-gen-go-grpc \
               bin/golangci-lint bin/goose bin/oapi-codegen \
               bin/mockery bin/gofumpt

bin/air:
	GOBIN=$(BIN_DIR) go install github.com/air-verse/air@v1.52.3

bin/protoc-gen-go:
	GOBIN=$(BIN_DIR) go install google.golang.org/protobuf/cmd/protoc-gen-go@v1.34.2

bin/protoc-gen-go-grpc:
	GOBIN=$(BIN_DIR) go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@v1.4.0

bin/golangci-lint:
	curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b $(BIN_DIR) v1.59.1

bin/goose:
	GOBIN=$(BIN_DIR) go install github.com/pressly/goose/v3/cmd/goose@v3.21.1

bin/oapi-codegen:
	GOBIN=$(BIN_DIR) go install github.com/oapi-codegen/oapi-codegen/v2/cmd/oapi-codegen@v2.4.1

bin/mockery:
	GOBIN=$(BIN_DIR) go install github.com/vektra/mockery/v2@v2.46.3

bin/gofumpt:
	GOBIN=$(BIN_DIR) go install mvdan.cc/gofumpt@v0.7.0

clean-tools:
	rm -rf $(BIN_DIR)

build:
	go build -o $(BUILD_DIR)/$(APP_NAME) ./cmd/server

run: build
	$(BUILD_DIR)/$(APP_NAME)

dev: bin/air
	$(BIN_DIR)/air -c .air.toml

test:
	go test ./... -v -race

lint: bin/golangci-lint
	$(BIN_DIR)/golangci-lint run ./...

fmt: bin/gofumpt
	$(BIN_DIR)/gofumpt -w .

proto: bin/protoc-gen-go bin/protoc-gen-go-grpc
	protoc --go_out=. --go_opt=paths=source_relative \
	       --go-grpc_out=. --go-grpc_opt=paths=source_relative \
	       api/proto/*.proto

generate-mocks: bin/mockery
	$(BIN_DIR)/mockery --all --dir=internal/

migrate-up: bin/goose
	$(BIN_DIR)/goose -dir internal/migrations postgres "$(DB_URL)" up

migrate-down: bin/goose
	$(BIN_DIR)/goose -dir internal/migrations postgres "$(DB_URL)" down

migrate-create: bin/goose
	$(BIN_DIR)/goose -dir internal/migrations create $(NAME) sql

docker-build:
	docker build -f deployments/Dockerfile -t $(APP_NAME) .

docker-up:
	docker compose -f deployments/docker-compose.yml up -d

docker-up-full:
	docker compose -f deployments/docker-compose.yml \
	               -f deployments/monitoring/docker-compose.monitoring.yml up -d

docker-down:
	docker compose -f deployments/docker-compose.yml \
	               -f deployments/monitoring/docker-compose.monitoring.yml down

docker-logs:
	docker compose -f deployments/docker-compose.yml logs -f app
