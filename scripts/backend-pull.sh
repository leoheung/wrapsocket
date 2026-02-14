#!/bin/bash

set -e

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BACKEND_DIR="$ROOT_DIR/go-patterns"

cd "$BACKEND_DIR"

BRANCH=$(git branch --show-current)

echo "📥 Pulling backend (go-patterns) from $BRANCH..."
git pull origin "$BRANCH" || git pull origin main || git pull origin master

echo "✅ Backend pulled successfully!"
