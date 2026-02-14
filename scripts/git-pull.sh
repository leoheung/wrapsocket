#!/bin/bash

set -e

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

echo "📥 Pulling main repository..."
git pull origin "$(git branch --show-current)"

echo "✅ Main repository pulled successfully!"
