#!/bin/bash

# Utils functions

# generate the white space
break_line() {
	echo -e "\n"
}

# create a question prompt
question() {
	local ask=$1

	while true; do
		# ask for confirmation
		read -r -p "-> $ask (y/n):" response
		# transform string to lower case
		response=$(echo "$response" | tr '[:upper:]' '[:lower:]')

		# check if answer is not equal to 'y' or 'n'
		if [ "$response" != "y" ] && [ "$response" != "n" ]; then
			show_warning_msg "Incorrect answer. Please type 'y (yes)' or 'n (no)'."
		# check if the answer is equal to “y
		elif [ "$response" = "y" ]; then
			show_info_msg "You choose 'y (yes)'."
			# return 0 when answer is equal to 'y (yes)'
			return 0
		else
			show_info_msg "You choose 'n (no)'."
			# return 0 when answer is equal to 'n (no)'
			return 1
		fi
	done
}

# Git functions

# fetch branches from remote
fetch_branches() {
	local git_remote=$1

	echo "-> Fetching all branches..."

	# fetch updates from the remote
	git fetch "$git_remote"
	# store the error code from git fetch update
	git_fetch_error_code=$?

	# check if git fetch failed
	if [ $git_fetch_error_code -ne 0 ]; then
		show_danger_msg "Error: Finished with error code $git_fetch_error_code."
		# exit with git fetch error code
		exit $git_fetch_error_code
	fi
}

# execute the git merge command
merge_branch() {
	local target_branch=$1

	echo -e "\n-> Merging branch $target_branch...\n"
	git merge --no-ff "$target_branch"
}

# check if exists git conflicts recursively
check_merge_conflicts() {
	local index=$1
	local conflicts
	conflicts=$(git status --porcelain)

	if [ -n "$conflicts" ]; then
		if [ "$index" -gt 0 ]; then
			show_warning_msg "There are still unresolved merge conflicts. Please resolve them before sending."
		else
			show_warning_msg "Merge conflicts detected. Please resolve them before pushing."
		fi

		question "Can you confirm the resolution of merge conflicts?"
		question_error_code=$?

		# check if question exited with an error code
		if [ $question_error_code -eq 0 ]; then
			# recursive action
			check_merge_conflicts $((index + 1))
		else
			return 1
		fi
	elif [ "$index" -gt 0 ]; then
		return 0
	else
		return 1
	fi
}

# execute the git push command
push_branch() {
	local git_remote=$1
	local branch=$2

	echo -e "-> Pushing branch $branch to remote...\n"
	git push -u "$git_remote" "$branch"
	break_line
}

# delete branch from remote and local
delete_branch() {
	local git_remote=$1
	local branch=$2

	if [[ $branch == *"$git_remote"* ]]; then
		echo -e "-> Deleting branch $branch from remote...\n"

		cleaned_branch_name=$(echo "$branch" | sed -e "s/$git_remote\///g")

		git push "$git_remote" --delete "$cleaned_branch_name"
		break_line
	fi

	echo -e "-> Deleting branch $branch from local...\n"
	git branch -D "$branch"
	break_line
}

# create a new tag and push to remote
create_and_push_tags() {
	local git_remote=$1
	local tag=$2

	echo -e "-> Pulling remote tags...\n"
	git pull "$git_remote" --tags

	echo -e "-> Creating tag $tag..."
	git tag "$tag"

	echo -e "-> Pushing to remote...\n"
	git push "$git_remote" "$tag"
	break_line
}
