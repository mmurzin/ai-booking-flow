#!/bin/bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
BIN_DIR="$ROOT_DIR/bin"

echo "Generating protobuf Go code..."

for proto in "$ROOT_DIR"/api/proto/*.proto; do
    if [ -f "$proto" ]; then
        protoc \
            --proto_path="$ROOT_DIR/api/proto" \
            --go_out="$ROOT_DIR" --go_opt=paths=source_relative \
            --go-grpc_out="$ROOT_DIR" --go-grpc_opt=paths=source_relative \
            "$proto"
        echo "  generated: $proto"
    fi
done

echo "Generating mocks..."
"$BIN_DIR/mockery" --all --dir="$ROOT_DIR/internal/" --output="$ROOT_DIR/internal/mocks" --dry-run=false 2>/dev/null || true

echo "Done."
