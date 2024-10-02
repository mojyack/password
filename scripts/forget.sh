#!/bin/zsh
# from https://github.com/nachoparker/git-forget-blob/blob/master/git-forget-blob.sh

set -e

export FILTER_BRANCH_SQUELCH_WARNING=1
git repack -Aq
for file in $@; do
    git filter-branch --index-filter "git rm --cached --ignore-unmatch '$file'" --force -- --branches --tags
done
rm -rf .git/refs/original/ .git/refs/remotes/ git/logs/
(git for-each-ref --format="%(refname)" refs/original/ || echo :) | xargs --no-run-if-empty -n1 git update-ref -d
git reflog expire --expire-unreachable=now --all
git repack -q -A -d
git gc --aggressive --prune=now
