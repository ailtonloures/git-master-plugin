#!/bin/bash

merge_branch() {
    local current_branch=$1
    local target_branch=$2

    echo -e "\n-> Pulling remote updates..."

    git checkout $target_branch
    git pull
    git checkout $current_branch
    git pull

    echo -e "\n-> Merging branch $target_branch..."

    git merge --no-ff $target_branch
}

push_branch() {
    local branch=$1

    echo "-> Pushing branch $branch..."

    git push -u $git_remote $branch
}

delete_branch() {
    local branch=$1

    echo "-> Deleting branch $branch..."

    git branch -D $branch
}
