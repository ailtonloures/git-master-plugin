#!/bin/bash

source $(dirname $0)/git-master-message.sh
source $(dirname $0)/git-master-functions.sh

string_to_lower_case() {
    echo $1 | tr '[:upper:]' '[:lower:]' # transform string to lower case
}

confirmation_input() {
    local question=$1
    read -p "-> $question (y/n): " response # ask for confirmation
}

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
    branches_opt=($branches "Finish merge" "Exit")                                                      # create list of options
    merged_branches_list=()                                                                             # merged branches list will start empty

    if [ -z "$branches" ]; then # check if branch list is empty
        show_warning_msg "There are no branches available to merge."
        exit 1 # exit with generic error code
    fi

    echo -e "-> Listing all branches...\n"
    PS3="Enter the number of your choice: " # select input

    select opt in "${branches_opt[@]}"; do # list all selectable branches
        case $opt in
        "Finish merge")
            # Finish merge option
            echo -e "\n-> Finishing the merge step..."

            if [ ${#merged_branches_list[@]} -eq 0 ]; then # check if has merged branches on list
                show_warning_msg "No branch has been merged."
            else
                echo -e "-> Merged branches:\n"

                for i in "${!merged_branches_list[@]}"; do   # get the index from the merged branch list
                    local branch=${merged_branches_list[$i]} # get the branch name from index
                    local index=$(expr $i + 1)               # get the index and increment

                    echo -e "\t$index - $branch\n"
                done

                while true; do # Push option
                    confirmation_input "Do you want to push the current branch ($current_branch)?"
                    response=$(string_to_lower_case $response)

                    if [ $response != "y" ] && [ $response != "n" ]; then # check if answer is not equal to 'y' or 'n'
                        show_warning_msg "Incorrect answer. Please type 'y (yes)' or 'n (no)'."
                    elif [ $response = "y" ]; then # check if the answer is equal to “y
                        show_info_msg "You choose 'y (yes)' to push current branch."

                        push_branch $current_branch
                        break
                    else
                        show_info_msg "You choose 'n (no)' to push current branch."
                        echo "-> wait"
                        break
                    fi
                done

                while true; do # Delete option
                    confirmation_input "Do you want to delete the merged branches?"
                    response=$(string_to_lower_case $response)

                    if [ $response != "y" ] && [ $response != "n" ]; then # check if answer is not equal to 'y' or 'n'
                        show_warning_msg "Incorrect answer. Please type 'y (yes)' or 'n (no)'."
                    elif [ $response = "y" ]; then # check if the answer is equal to “y
                        show_info_msg "You choose 'y (yes)' to delete merged branches."

                        for branch in "${merged_branches_list[@]}"; do # get the branch name from the merged branch list
                            delete_branch $branch
                        done
                        break
                    else
                        show_info_msg "You choose 'n (no)' to delete merged branches."
                        echo "-> wait"
                        break
                    fi
                done
            fi
            ;;
        "Exit")
            # Exit option
            show_success_msg "Git Master finished successfully!"
            exit 0 # exit with success code
            break
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
            fi
            ;;
        esac
    done
fi
