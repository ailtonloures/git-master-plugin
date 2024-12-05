#!/bin/bash

# shellcheck source=/dev/null
source "$(dirname "$0")"/message.sh

if [ -t 0 ]; then
	main_path=$(pwd)/main.sh

	chmod +x "$main_path"
	git config --global alias.master "!bash $main_path"
	git_config_error_code=$?

	if [ $git_config_error_code -ne 0 ]; then
		show_danger_msg "Error: An error occurred while trying to configure Git Master."
		exit 1
	fi

	show_success_msg "Git master has been successfully configured!"
	exit 0
fi
