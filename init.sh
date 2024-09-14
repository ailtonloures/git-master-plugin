#!/bin/bash

source $(dirname $0)/message.sh

if [ -t 0 ]; then
    main_path=$(echo "$(pwd)/main.sh")

    chmod +x $main_path
    git config --global alias.master "!bash $main_path"

    if [ $? -ne 0 ]; then
        show_danger_msg "Error: An error occurred while trying to configure Git Master."
        exit 1
    fi

    show_success_msg "Git master has been successfully configured!"
    exit 0
fi
