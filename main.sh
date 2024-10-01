#!/bin/bash

# shellcheck source=/dev/null
source "$(dirname "$0")"/message.sh
source "$(dirname "$0")"/functions.sh

if [ -t 0 ]; then
	current_branch=$(git branch --show-current) # get the current branch

	echo -e "\n!Initializing the Git Master on branch $current_branch!\n"

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

	fetch_branches "$git_remote"

	git_branch=$(git branch --all --list '*feature*' --list '*hotfix*' --list '*fix*' --list '*release*' | grep -v "^\*") # list all branches (feature/hotfix/fix/release)

	if [ -z "$git_branch" ]; then # check if branch list is empty
		show_warning_msg "There are no branches available to merge."
		exit 1 # exit with generic error code
	fi

	branches_list=()        # create list of options
	merged_branches_list=() # merged branches list will start empty

	for branch in "${git_branch[@]}"; do
		renamed_branch=$(echo "$branch" | sed -e "s/remotes\///g")
		branches_list+=("$renamed_branch")
	done

	opt_list=($(printf "%s\n" "${branches_list[@]}" | sort | uniq) "Exit")

	echo -e "-> Listing all branches...\n"
	PS3="Choose a branch to merge: " # select input

	select opt in "${opt_list[@]}"; do # list all selectable branches
		case $opt in
		"Exit")
			# Exit option
			show_success_msg "Exit..."
			exit 0 # exit with success code
			;;
		*)
			# Default option
			if [ -z "$opt" ]; then # check if an option does not exist
				show_danger_msg "Invalid option!"
			else
				target_branch=$opt

				merge_branch "$target_branch"
				merge_error_code=$? # store the error code from git fetch update

				if [ $merge_error_code -ne 0 ]; then
					check_merge_conflicts 0 # checks for merge conflicts recursively

					if [ $? -eq 1 ]; then # checks that conflicts have not been resolved correctly
						show_danger_msg "Error: Failed to merge branch $target_branch. With error code $merge_error_code"
						exit $merge_error_code # exit with git merge error code
					fi
				fi

				show_success_msg "Merged branch $target_branch successfully!"

				merged_branches_list+=("$target_branch") # add the target branch to merged branches list

				question "Do you want to continue?"

				if [ $? -eq 1 ]; then # check if user doesn't want to continue the merge operation
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
		branch=${merged_branches_list[$i]}        # get the branch name from index
		index=$((i + 1))                          # get the index and increment

		echo -e "\t$index - $branch\r"
	done

	echo -e "\n"

	question "Do you want to push the current branch ($current_branch)?"
	question_error_code=$?

	if [ $question_error_code -eq 0 ]; then # check if user wants to push the current branch
		push_branch "$git_remote" "$current_branch"
	fi

	question "Do you want to create a new tag?"
	question_error_code=$?

	if [ $question_error_code -eq 0 ]; then # check if user wants to create a new tag
		echo "-> Tag name: "
		read -r value # get the tag name
		create_and_push_tags "$git_remote" "$value"
	fi

	question "Do you want to delete the merged branches?"
	question_error_code=$?

	if [ $question_error_code -eq 0 ]; then         # check if user wants to delete the merged branches
		for branch in "${merged_branches_list[@]}"; do # get the branch name from the merged branch list
			delete_branch "$git_remote" "$branch"
		done
	fi

	show_success_msg "Git Master finished successfully!"
	exit 0
fi
