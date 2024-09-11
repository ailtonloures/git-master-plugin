#!/bin/bash

source ./git-master-colors.sh
source ./git-master-functions.sh

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

    echo -e "\nListing all branches on your remote\n"

    branches=$(git branch --remotes --list | grep -vE "master|main|HEAD")
    branches_opt=($branches "Exit")

    PS3="Enter the number of your choice: "

    select opt in "${branches_opt[@]}"; do
        case $opt in
        "Exit")
            echo -e "\n$success""Git Master finished successfully!"
            exit 0
            break
            ;;
        *)
            if [ -z "$opt" ]; then
                echo -e "\n$error""Invalid option""$default\n"
            fi

            merge_branch $opt
            ;;
        esac
    done
fi
