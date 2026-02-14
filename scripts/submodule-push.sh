#!/bin/bash

set -e

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

echo "📤 Pushing all submodules..."

git submodule foreach 'echo "📤 Pushing \$name..." && git push origin \$(git branch --show-current) || echo "⚠️ No remote branch to push"'

echo "✅ All submodules pushed successfully!"
