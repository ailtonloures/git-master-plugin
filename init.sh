#!/bin/bash

if [ -t 0 ]; then
    main_path=$(echo "$(pwd)/main.sh")

    chmod +x $main_path
    git config --global alias.master "!bash $main_path"
fi
