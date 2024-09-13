#!/bin/bash

source $(dirname $0)/message.sh
source $(dirname $0)/functions.sh

if [ -t 0 ]; then
    current_branch=$(git branch --show-current) # get the current branch

    echo -e "\n!Initializing the Git Master on branch $color_info$current_branch$color_default!\n"

    if [ ! -d ".git" ]; then # checks if repository has been initialized
        show_danger_msg "Error: The git repository not configured properly."
        show_info_msg "Please use git init to initialize a new git repository..."
        exit 1 # exit with generic error
    fi

    git_remote=$(git remote) # get the remote from the git repository

    if [ -z "$git_remote" ]; then # check if remote exists
        show_danger_msg "Error: Remote repository address is not configured."
        show_info_msg "Please use git remote add origin <newurl> to set the remote."
        exit 1 # exit with generic error code
    fi

    echo "-> Fetching all branches..."

    git_fetch=$(git fetch $git_remote) # fetch updates from the remote
    git_fetch_error_code=$?            # store the error code from git fetch update

    if [ $git_fetch_error_code -ne 0 ]; then # check if git fetch failed
        show_danger_msg "Error: Finished with error code $git_fetch_error_code."
        exit $git_fetch_error_code # exit with git fetch error code
    fi

    branches=$(git branch --all --list '*feature*' --list '*hotfix*' --list '*fix*' --list '*release*') # list all branches (feature/hotfix/fix/release)
    branches_opt=($branches "Exit")                                                                     # create list of options
    merged_branches_list=()                                                                             # merged branches list will start empty

    if [ -z "$branches" ]; then # check if branch list is empty
        show_warning_msg "There are no branches available to merge."
        exit 1 # exit with generic error code
    fi

    echo -e "-> Listing all branches...\n"
    PS3="Choose a branch to merge: " # select input

    select opt in "${branches_opt[@]}"; do # list all selectable branches
        case $opt in
        "Exit")
            # Exit option
            show_success_msg "Leaving..."
            exit 0 # exit with success code
            ;;
        *)
            # Default option
            if [ -z "$opt" ]; then # check if an option does not exist
                show_danger_msg "Invalid option!"
            else
                target_branch=$(echo "$opt" | sed -e "s/remotes\/$git_remote\///g") # takes the selected branch and removes the remote information
                merge_branch $current_branch $target_branch
                show_success_msg "Merged branch $target_branch successfully!"

                merged_branches_list+=("$target_branch") # add the target branch to merged branches list

                question "Do you want to continue?"

                if [ $? -eq 0 ]; then # check if user wants to delete the merged branches
                    echo -e "-> Finishing the merge step..."
                    break
                fi
            fi
            ;;
        esac
    done

    if [ ${#merged_branches_list[@]} -eq 0 ]; then # check if has merged branches on list
        show_warning_msg "No branch has been merged."
        exit 1 # exit with generic error code
    fi

    echo -e "-> Merged branches:\n"

    for i in "${!merged_branches_list[@]}"; do # get the index from the merged branch list
        branch=${merged_branches_list[$i]}     # get the branch name from index
        index=$(expr $i + 1)                   # get the index and increment

        echo -e "\t$index - $branch\n"
    done

    question "Do you want to push the current branch ($current_branch)?"

    if [ $? -eq 0 ]; then # check if user wants to push the current branch
        push_branch $current_branch
    fi

    question "Do you want to create a new tag?"

    if [ $? -eq 0 ]; then  # check if user wants to create a new tag
        input "Tag name: " # get the tag name
        create_and_push_tags $value
    fi

    question "Do you want to delete the merged branches?"

    if [ $? -eq 0 ]; then                              # check if user wants to delete the merged branches
        for branch in "${merged_branches_list[@]}"; do # get the branch name from the merged branch list
            delete_branch $branch
        done
    fi

    show_success_msg "Git Master finished successfully!"
    exit 0
fi
