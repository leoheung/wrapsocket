#!/bin/bash

set -e

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BACKEND_DIR="$ROOT_DIR/go-patterns"

cd "$BACKEND_DIR"

BRANCH=$(git branch --show-current)

echo "📤 Pushing backend (go-patterns) to $BRANCH..."
git push origin "$BRANCH"

echo "✅ Backend pushed successfully!"
