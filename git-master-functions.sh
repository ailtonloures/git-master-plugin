#!/bin/bash

merge_branch() {
    local current_branch=$1
    local target_branch=$2

    echo -e "-> Pulling branch $target_branch..."

    git checkout $target_branch
    git checkout $current_branch

    echo -e "-> Merging branch $target_branch..."

    git merge --no-ff $target_branch
}

push_branch() {
    local branch=$1

    echo -e "-> Pushing branch $branch..."
}

delete_branch() {
    local branch=$1

    echo -e "-> Deleting branch $branch..."
}
