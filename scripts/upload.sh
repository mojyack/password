#!/bin/zsh

set -e

# remove previous update commit
target_hash=$(git log --oneline --grep="database update" | cut -d ' ' -f 1)
git rebase --onto "$target_hash^" "$target_hash"

# commit database files
git add *.enc
git commit -m "database update $(date '+%Y-%m-%d %H:%M')"

git push -f
