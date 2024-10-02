#!/bin/zsh

set -e

find_commit() {
    git log --oneline --grep="$1" | cut -d ' ' -f 1
}

export GIT_EDITOR=true
git add *.enc
git commit --fixup=$(find_commit "database update")
git rebase -i --autosquash $(find_commit "initial commit")
git reflog expire --expire=now --expire-unreachable=now --all
git repack -a -d

git push -f
