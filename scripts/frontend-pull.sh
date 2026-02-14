#!/bin/bash

set -e

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FRONTEND_DIR="$ROOT_DIR/wrapsocket-ts"

cd "$FRONTEND_DIR"

BRANCH=$(git branch --show-current)

echo "📥 Pulling frontend (wrapsocket-ts) from $BRANCH..."
git pull origin "$BRANCH" || git pull origin main || git pull origin master

echo "✅ Frontend pulled successfully!"
