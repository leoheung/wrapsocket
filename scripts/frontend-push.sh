#!/bin/bash

set -e

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FRONTEND_DIR="$ROOT_DIR/wrapsocket-ts"

cd "$FRONTEND_DIR"

BRANCH=$(git branch --show-current)

echo "📤 Pushing frontend (wrapsocket-ts) to $BRANCH..."
git push origin "$BRANCH"

echo "✅ Frontend pushed successfully!"
