#!/bin/bash

set -e

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

echo "🔄 Pulling everything..."
echo "========================"

echo ""
echo "📥 Pulling main repository..."
git pull origin "$(git branch --show-current)"

echo ""
echo "📥 Pulling all submodules..."
git submodule foreach 'echo "📥 Pulling \$name..." && git pull origin \$(git branch --show-current) || git pull origin main || git pull origin master || true'

echo ""
echo "✅ All repositories pulled successfully!"
