#!/bin/bash

# shellcheck source=/dev/null
source "$(dirname "$0")"/message.sh
source "$(dirname "$0")"/functions.sh

if [ -t 0 ]; then
	# get the current branch
	current_branch=$(git branch --show-current)

	echo -e "\nInitializing the Git Master on branch $current_branch\n"

	# checks if repository has been initialized
	if [ ! -d ".git" ]; then
		show_danger_msg "Error: The git repository not configured properly."
		show_info_msg "Please use git init to initialize a new git repository..."
		# exit with generic error
		exit 1
	fi

	# get the remote from the git repository
	git_remote=$(git remote)

	# check if remote exists
	if [ -z "$git_remote" ]; then
		show_danger_msg "Error: Remote repository address is not configured."
		show_info_msg "Please use git remote add origin <newurl> to set the remote."
		# exit with generic error code
		exit 1
	fi

	fetch_branches "$git_remote"

	# list all branches (feature/hotfix/fix/release)
	git_branch=$(git branch --all --list '*feature*' --list '*hotfix*' --list '*fix*' --list '*release*' | grep -v "^\*")

	# check if branch list is empty
	if [ -z "$git_branch" ]; then
		show_warning_msg "There are no branches available to merge."
		# exit with generic error code
		exit 1
	fi

	# create list of options
	branches_list=()
	# merged branches list will start empty
	merged_branches_list=()

	for branch in "${git_branch[@]}"; do
		renamed_branch=$(echo "$branch" | sed -e "s/remotes\///g")
		branches_list+=("$renamed_branch")
	done

	opt_list=($(printf "%s\n" "${branches_list[@]}" | sort | uniq) "Exit")

	echo -e "-> Listing all branches...\n"
	# select input
	PS3="Choose a branch to merge: "

	# list all selectable branches
	select opt in "${opt_list[@]}"; do
		case $opt in
		"Exit")
			# Exit option
			show_success_msg "Exit..."
			# exit with success code
			exit 0
			;;
		*)
			# Default option
			# check if an option does not exist
			if [ -z "$opt" ]; then
				show_danger_msg "Invalid option!"
			else
				target_branch=$opt

				merge_branch "$target_branch"
				# store the error code from git fetch update
				merge_error_code=$?

				if [ $merge_error_code -ne 0 ]; then
					# checks for merge conflicts recursively
					check_merge_conflicts 0

					# checks that conflicts have not been resolved correctly
					if [ $? -eq 1 ]; then
						show_danger_msg "Error: Failed to merge branch $target_branch. With error code $merge_error_code"
						# exit with git merge error code
						exit $merge_error_code
					fi
				fi

				break_line
				show_success_msg "Merged branch $target_branch successfully!"

				# add the target branch to merged branches list
				merged_branches_list+=("$target_branch")

				question "Do you want to continue?"

				# check if user doesn't want to continue the merge operation
				if [ $? -eq 1 ]; then
					echo -e "-> Finishing the merge step..."
					break
				fi
			fi
			;;
		esac
	done

	# check if has merged branches on list
	if [ ${#merged_branches_list[@]} -eq 0 ]; then
		show_warning_msg "No branch has been merged."
		# exit with generic error code
		exit 1
	fi

	echo -e "-> Merged branches:\n"

	# get the index from the merged branch list
	for i in "${!merged_branches_list[@]}"; do
		# get the branch name from index
		branch=${merged_branches_list[$i]}
		# get the index and increment
		index=$((i + 1))

		echo -e "\t$index - $branch\r"
	done

	break_line

	question "Do you want to push the current branch ($current_branch)?"
	question_error_code=$?

	# check if user wants to push the current branch
	if [ $question_error_code -eq 0 ]; then
		push_branch "$git_remote" "$current_branch"
	fi

	if [ "$current_branch" == "main" ] || [ "$current_branch" == "master" ] || [[ "$current_branch" == *"release"* ]] || [ "$current_branch" == "develop" ]; then
		question "Do you want to create a new tag?"
		question_error_code=$?

		# check if user wants to create a new tag
		if [ $question_error_code -eq 0 ]; then
			# get the tag name
			read -r -p "-> Tag name: " value
			create_and_push_tags "$git_remote" "$value"
		fi

		question "Do you want to delete the merged branches?"
		question_error_code=$?

		# check if user wants to delete the merged branches
		if [ $question_error_code -eq 0 ]; then
			# get the branch name from the merged branch list
			for branch in "${merged_branches_list[@]}"; do
				delete_branch "$git_remote" "$branch"
			done
		fi
	fi

	show_success_msg "Git Master finished successfully!"
	exit 0
fi
