#!/bin/bash

branch=$(git symbolic-ref --short HEAD 2>/dev/null)
modified=$(git status --short 2>/dev/null)
stash=$(git stash list 2>/dev/null)

if [ -n "$branch" ]; then
  if [ -n "$modified" ]; then
    echo -e "[\e[91m$branch\e[0m]"
  elif [ -n "$stash" ]; then
    echo -e "[\e[93m$branch\e[0m]"
  else
    echo -e "[\e[92m$branch\e[0m]"
  fi
fi
