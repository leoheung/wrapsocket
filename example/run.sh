#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

echo "🔨 Building TypeScript..."
cd "$ROOT_DIR/wrapsocket-ts"
npm run build

echo ""
echo "🚀 Starting Go server..."
cd "$SCRIPT_DIR"
GOPROXY=off go run main.go
