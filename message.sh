#!/bin/bash

# colors
color_danger="\033[1;31m"  # red
color_success="\033[0;32m" # green
color_info="\033[0;36m"    # cyan
color_warning="\033[1;33m" # yellow
color_default="\033[0m"    # white

show_success_msg() {
	echo -e "$color_success""$1""$color_default\n"
}

show_danger_msg() {
	echo -e "$color_danger""$1""$color_default\n"
}

show_warning_msg() {
	echo -e "$color_warning""$1""$color_default\n"
}

show_info_msg() {
	echo -e "$color_info""$1""$color_default\n"
}
