NAME=saml2aws
ARCH=$(shell uname -m)
VERSION=2.28.0
ITERATION := 1

GOLANGCI_VERSION = 1.45.2
GORELEASER_VERSION = 0.157.0

SOURCE_FILES?=$$(go list ./... | grep -v /vendor/)
TEST_PATTERN?=.
TEST_OPTIONS?=

BIN_DIR := $(CURDIR)/bin

ci: prepare test

mod:
	@go mod download
	@go mod tidy
.PHONY: mod

lint: 
	@echo "--- lint all the things"
	@docker run --rm -v $(shell pwd):/app -w /app golangci/golangci-lint:v$(GOLANGCI_VERSION) golangci-lint run -v
.PHONY: lint

lint-fix:
	@echo "--- lint all the things"
	@docker run --rm -v $(shell pwd):/app -w /app golangci/golangci-lint:v$(GOLANGCI_VERSION) golangci-lint run -v --fix
.PHONY: lint-fix

fmt: lint-fix

install:
	go install ./cmd/saml2aws
.PHONY: mod

build: $(BIN_DIR)/goreleaser
	$(BIN_DIR)/goreleaser build --snapshot --rm-dist
.PHONY: build

clean:
	@rm -fr ./build
.PHONY: clean

generate-mocks:
	mockery -dir pkg/prompter --all
	mockery -dir pkg/provider/okta -name U2FDevice
.PHONY: generate-mocks

test:
	@echo "--- test all the things"
	@go test -cover ./...
.PHONY: test
