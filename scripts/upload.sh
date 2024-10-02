#!/bin/zsh

set -e

git commit -a --fixup=$(git log --oneline --grep="database update" | cut -d ' ' -f 1)
git reflog expire --expire=now --expire-unreachable=now --all
git repack -a -d
git push -f
