#!/bin/bash

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

echo "📊 Submodule Status:"
echo "=================="
git submodule status

echo ""
echo "📋 Detailed Status:"
echo "=================="
git submodule foreach 'echo "--- \$name ---" && git status -s && echo ""'
