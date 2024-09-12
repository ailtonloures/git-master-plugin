#!/bin/bash

source ./git-master-colors.sh
source ./git-master-functions.sh

if [ -t 0 ]; then
    current_branch=$(git branch --show-current)

    echo -e "\nInitializing the Git Master on branch $info$current_branch$default"

    if [ ! -d ".git" ]; then
        echo -e "$danger""Error: The git repository not configured properly."
        echo -e "\n$info""Please, use git init to initialize a new git repository..."
        exit 1
    fi

    git_remote=$(git remote)

    if [ -z "$git_remote" ]; then
        echo -e "$danger""Error: Remote repository address is not configured."
        echo -e "\n$info""Please, use git remote add origin <newurl> to set the remote"
        exit 1
    fi

    git_fetch=$(git fetch $git_remote)
    git_fetch_error_code=$?

    if [ $git_fetch_error_code -ne 0 ]; then
        echo -e "$danger""Error: Finished with error code $git_fetch_error_code"
        exit $git_fetch_error_code
    fi

    branches=$(git branch --all --list | grep -vE "master|main|HEAD")
    branches_opt=($branches "Push current branch" "Finish merged branches" "Exit")

    if [ -z "$branches" ]; then
        echo -e "\n$warning""There are no branches available to merge."
        exit 0
    fi

    echo -e "\nListing all branches\n"
    PS3="Enter the number of your choice: "

    select opt in "${branches_opt[@]}"; do
        case $opt in
        "Push current branch")
            push_branch $current_branch
            exit 0
            ;;
        "Finish merged branches")
            delete_branch $current_branch
            exit 0
            ;;
        "Exit")
            echo -e "\n$success""Git Master finished successfully!"
            exit 0
            break
            ;;
        *)
            if [ -z "$opt" ]; then
                echo -e "\n$danger""Invalid option""$default\n"
            else
                target_branch=$(echo "$opt" | sed -e "s/remotes\/$git_remote\///g")
                merge_branch $current_branch $target_branch
            fi
            ;;
        esac
    done
fi
