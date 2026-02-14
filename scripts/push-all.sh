#!/bin/bash

set -e

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

echo "📤 Pushing everything..."
echo "========================"

echo ""
echo "📤 Pushing all submodules..."
git submodule foreach 'echo "📤 Pushing \$name..." && git push origin \$(git branch --show-current) || echo "⚠️ No changes to push in \$name"'

echo ""
echo "📤 Pushing main repository..."
git push origin "$(git branch --show-current)"

echo ""
echo "✅ All repositories pushed successfully!"
