#!/bin/bash

# colors
error="\033[1;31m"
success="\033[0;32m"
info="\033[0;36m"

if [ -t 0 ]; then
    echo -e "\nInitializing the Git Master..."

    if [ ! -d ".git" ]; then
        echo -e "$error""Error: The git repository not configured properly."
        echo -e "\n$info""Please, use git init to initialize a new git repository..."
        exit 1
    fi

    git_remote=$(git remote)

    if [ -z "$git_remote" ]; then
        echo -e "$error""Error: Remote repository address is not configured."
        echo -e "\n$info""Please, use git remote add origin <newurl> to set the remote"
        exit 1
    fi
fi
