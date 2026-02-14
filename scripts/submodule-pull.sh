#!/bin/bash

set -e

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

echo "📥 Pulling all submodules..."

git submodule foreach 'echo "📥 Pulling \$name..." && git pull origin \$(git branch --show-current) || git pull origin main || git pull origin master'

echo "✅ All submodules pulled successfully!"
