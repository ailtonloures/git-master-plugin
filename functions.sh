#!/bin/bash

break_line() {
    echo -e "\n"
}

input() {
    read -p "-> $1" value
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

merge_branch() {
    local target_branch=$1

    echo -e "\n-> Merging branch $target_branch...\n"
    git merge --no-ff $target_branch
}

check_merge_conflicts() {
    local conflicts=$(git status --porcelain)

    if [ ! -z "$conflicts" ]; then
        show_warning_msg "Merge conflicts detected. Please resolve them before pushing."

        while true; do
            if [ -z "$conflicts" ]; then
                show_info_msg "Merge conflicts resolved successfully."
                return 0
            fi
        done
    else
        return 1
    fi
}

push_branch() {
    local branch=$1

    echo -e "-> Pushing branch $branch to remote...\n"
    git push -u $git_remote $branch
    break_line
}

delete_branch() {
    local branch=$1

    if [[ $branch == *"$git_remote"* ]]; then
        echo -e "-> Deleting branch $branch from remote...\n"

        cleaned_branch_name=$(echo "$branch" | sed -e "s/$git_remote\///g")

        git push $git_remote --delete $cleaned_branch_name
        break_line
    else
        echo -e "-> Deleting branch $branch from local...\n"
        git branch -D $branch
        break_line
    fi
}

create_and_push_tags() {
    local tag=$1

    echo -e "-> Pulling remote tags...\n"
    git pull --tags

    echo -e "-> Creating tag $tag..."
    git tag $tag

    echo -e "-> Pushing to remote...\n"
    git push $git_remote $tag
    break_line
}
