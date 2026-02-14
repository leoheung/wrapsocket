#!/bin/bash

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

echo "📊 WarpSocket Repository Status"
echo "================================"

echo ""
echo "📁 Main Repository:"
echo "   Branch: $(git branch --show-current)"
echo "   Status:"
git status -s | sed 's/^/   /'

echo ""
echo "📁 Submodules:"
git submodule status | while read line; do
    echo "   $line"
done

echo ""
echo "📋 Detailed Submodule Status:"
echo "================================"
git submodule foreach 'echo "" && echo "📦 \$name" && echo "   Branch: \$(git branch --show-current)" && echo "   Status:" && git status -s | sed "s/^/   /"'

echo ""
echo "================================"
echo "✅ Status check complete!"
