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

    echo "-> Pushing branch $branch to remote..."

    git push -u $git_remote $branch
}

delete_branch() {
    local branch=$1

    echo "-> Deleting branch $branch from local..."

    git branch -D $branch
}

create_and_push_tags() {
    local tag=$1

    echo "-> Creating tag $tag..."

    git pull --tags
    git tag $tag

    echo "-> Pushing to remote..."

    git push $git_remote $tag
}

question() {
    local ask=$1

    while true; do
        read -p "-> $ask (y/n): " response                        # ask for confirmation
        response=$(echo "$response" | tr '[:upper:]' '[:lower:]') # transform string to lower case

        if [ $response != "y" ] && [ $response != "n" ]; then # check if answer is not equal to 'y' or 'n'
            show_warning_msg "Incorrect answer. Please type 'y (yes)' or 'n (no)'."
        elif [ $response = "y" ]; then # check if the answer is equal to “y
            show_info_msg "You choose 'y (yes)'."
            return 0 # return 0 when answer is equal to 'y (yes)'
        else
            show_info_msg "You choose 'n (no)'."
            return 1 # return 0 when answer is equal to 'n (no)'
        fi
    done
}

input() {
    read -p "-> $1" value
}
