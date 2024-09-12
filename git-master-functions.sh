#!/bin/bash

merge_branch() {
    current_branch=$1
    target_branch=$2

    echo -e "\n$warning""Pulling branch $target_branch...""$default"

    git checkout $target_branch
    git checkout $current_branch

    echo -e "$warning""Merging branch $target_branch...""$default\n"

    git merge --no-ff $target_branch
}

push_branch() {
    current_branch=$1

    echo -e "\n$warning""Pushing branch $current_branch...""$default"
}

delete_branch() {
    branch=$1

    echo -e "\n$warning""Deleting branch $branch...""$default"
}
