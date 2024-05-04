#!/bin/zsh

git commit -am "update $(date '+%Y-%m-%d %H:%M')" --amend
git push -f origin HEAD:main
