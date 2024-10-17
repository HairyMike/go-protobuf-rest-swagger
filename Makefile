# Variables
PROTOC_VERSION=3.21.12
PROTOC_GEN_GO_VERSION=v1.31.0
PROTOC_GEN_GO_GRPC_VERSION=v1.2.0
PROTOC_GEN_OPENAPI_VERSION=v2.14.0

GOOGLEAPIS_REPO=https://github.com/googleapis/googleapis.git
GOOGLEAPIS_DIR=./googleapis

# Tools directories
BIN_DIR := $(HOME)/go/bin
PROTOC_DIR := /usr/local/bin

# Paths
PROTO_FILES := $(wildcard *.proto)
GO_OUT_DIR := .
SWAGGER_OUT_DIR := ./swagger

# Determine OS and Architecture (macOS detection for ARM64)
OS := $(shell uname -s | tr '[:upper:]' '[:lower:]')
ARCH := $(shell uname -m | tr '[:upper:]' '[:lower:]')

# Ensure correct OS string for Mac (darwin)
ifeq ($(OS),darwin)
  OS_NAME := osx
else
  OS_NAME := $(OS)
endif

# URLs for downloading protoc based on architecture
ifeq ($(ARCH),arm64)
  PROTOC_INSTALL_CMD := brew install protobuf
else
  PROTOC_ZIP_URL := https://github.com/protocolbuffers/protobuf/releases/download/v$(PROTOC_VERSION)/protoc-$(PROTOC_VERSION)-$(OS_NAME)-x86_64.zip
  PROTOC_INSTALL_CMD := curl -LO $(PROTOC_ZIP_URL) && unzip protoc-$(PROTOC_VERSION)-$(OS_NAME)-*.zip -d /usr/local && rm protoc-$(PROTOC_VERSION)-$(OS_NAME)-*.zip
endif

# Install protoc (if not already installed)
install_protoc:
	@if ! [ -x "$(PROTOC_DIR)/protoc" ]; then \
		echo "Installing protoc..." && \
		$(PROTOC_INSTALL_CMD); \
	else \
		echo "protoc is already installed"; \
	fi

# Install protoc-gen-go plugin
install_protoc_gen_go:
	@if ! [ -x "$(BIN_DIR)/protoc-gen-go" ]; then \
		echo "Installing protoc-gen-go..." && \
		go install google.golang.org/protobuf/cmd/protoc-gen-go@$(PROTOC_GEN_GO_VERSION); \
	else \
		echo "protoc-gen-go is already installed"; \
	fi

# Install protoc-gen-go-grpc plugin
install_protoc_gen_go_grpc:
	@if ! [ -x "$(BIN_DIR)/protoc-gen-go-grpc" ]; then \
		echo "Installing protoc-gen-go-grpc..." && \
		go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@$(PROTOC_GEN_GO_GRPC_VERSION); \
	else \
		echo "protoc-gen-go-grpc is already installed"; \
	fi

# Install grpc-gateway OpenAPI generator
install_protoc_gen_openapi:
	@if ! [ -x "$(BIN_DIR)/protoc-gen-openapiv2" ]; then \
		echo "Installing protoc-gen-openapiv2..." && \
		go install github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-openapiv2@$(PROTOC_GEN_OPENAPI_VERSION); \
	else \
		echo "protoc-gen-openapiv2 is already installed"; \
	fi

# Clone googleapis repo if not already cloned
install_google_apis:
	@if [ ! -d "$(GOOGLEAPIS_DIR)" ]; then \
		echo "Cloning Google API protos..." && \
		git clone $(GOOGLEAPIS_REPO); \
	else \
		echo "Google API protos already cloned"; \
	fi

# Generate Go and Swagger code from Protobuf
generate: install_protoc install_protoc_gen_go install_protoc_gen_go_grpc install_protoc_gen_openapi install_google_apis
	@echo "Generating Go and gRPC code..."
	protoc -I. -I$(GOOGLEAPIS_DIR) \
	  --go_out=$(GO_OUT_DIR) --go-grpc_out=$(GO_OUT_DIR) \
	  $(PROTO_FILES)

	@echo "Generating REST proxy and Swagger docs..."
	protoc -I. -I$(GOOGLEAPIS_DIR) \
	  --grpc-gateway_out=$(GO_OUT_DIR) \
	  --openapiv2_out=$(SWAGGER_OUT_DIR) \
	  $(PROTO_FILES)

# Clean generated code
clean:
	@echo "Cleaning generated files..."
	rm -rf $(GO_OUT_DIR)/*
	rm -rf $(SWAGGER_OUT_DIR)/*

# Run everything (install tools and generate code)
all: generate

.PHONY: install_protoc install_protoc_gen_go install_protoc_gen_go_grpc install_protoc_gen_openapi install_google_apis generate clean all
