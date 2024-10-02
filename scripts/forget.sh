#!/bin/zsh
# from https://github.com/nachoparker/git-forget-blob/blob/master/git-forget-blob.sh

set -e

file=$1

export FILTER_BRANCH_SQUELCH_WARNING=1
git repack -Aq
git branch -a | grep "remotes\/" | awk '{ print $1 }' | cut -f2 -d/ | while read -r r; do git remote rm "$r" 2>/dev/null; done
git filter-branch --index-filter "git rm --cached --ignore-unmatch '$file'" --force -- --branches --tags
rm -rf .git/refs/original/ .git/refs/remotes/ .git/*_HEAD .git/logs/
(git for-each-ref --format="%(refname)" refs/original/ || echo :) | xargs --no-run-if-empty -n1 git update-ref -d
git reflog expire --expire-unreachable=now --all
git repack -q -A -d
git gc --aggressive --prune=now
