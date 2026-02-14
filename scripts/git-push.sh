#!/bin/bash

set -e

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

BRANCH=$(git branch --show-current)

echo "📤 Pushing main repository to $BRANCH..."
git push origin "$BRANCH"

echo "✅ Main repository pushed successfully!"
