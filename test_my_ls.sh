#!/bin/bash

# Variables and functions definition

dir=$HOME/.tmp_tests_my_ls
me=`basename "$0"`

reload_perms () {
  sudo chmod -R 666 dir/
}

# Header

echo -e "\e[31m\033[1m
###################################################################################################
#                                  .__                 __                   __                    #
#                 _____ ___.__.    |  |   ______     _/  |_  ____   _______/  |_                  #
#                /     <   |  |    |  |  /  ___/     \   __\/ __ \ /  ___/\   __\\                 #
#               |  Y Y  \___  |    |  |__\___ \       |  | \  ___/ \___ \  |  |                   #
#               |__|_|  / ____|____|____/____  >      |__|  \___  >____  > |__|                   #
#                     \/\/   /_____/         \/                 \/     \/                         #
#     ___.               _________ .__                                __        .____             #
#     \_ |__ ___.__.     \_   ___ \|  |   ____   _____   ____   _____/  |_      |    |            #
#      | __ <   |  |     /    \  \/|  | _/ __ \ /     \_/ __ \ /    \   __\     |    |            #
#      | \_\ \___  |     \     \___|  |_\  ___/|  Y Y  \  ___/|   |  \  |       |    |___         #
#      |___  / ____|      \______  /____/\___  >__|_|  /\___  >___|  /__|       |_______ \ /\\     #
#          \/\/                  \/          \/      \/     \/     \/                   \/ \/     #
#                                                                                                 #
###################################################################################################\033[0m\n"
echo -e "\e[32mIf the program asks for your sudo password, don't worry, it's to avoid permissions issues\033[0m\n"
read -p "Press enter to continue"
echo ""

# Recompile with Makefile

make re > /dev/null

# Create temporary directory for tests

if ! mkdir dir; then
    echo -e "\e[31m\033[1m[ERROR] Failed to create temporary directory, already exist"
    echo -e "        Please delete it or rename in script\033[0m\n"
    exit 84
fi
reload_perms

# Send ls & my_ls outputs in files in the temporary directory

ls > dir/ls
./my_ls > dir/my_ls
reload_perms

# Compare outputs

diff dir/ls dir/my_ls > dir/diff
echo -e "\e[36m\033[1m//Test#1\033[0m"
echo -e "\e[36mls / ./my_ls"
if [ -s dir/diff ]; then
    echo -e "Outputs are differents"
    cat dir/diff
else
    echo -e "All is good\033[0m"
fi

# Delete temporary files & directory

if ! rm dir/ls; then
    echo -e "\e[31m\033[1m[ERROR] Failed to delete temporary file ($dir/ls)"
    echo -e "        Try 'sudo ./$me'\033[0m\n"
fi
if ! rm dir/my_ls; then
    echo -e "\e[31m\033[1m[ERROR] Failed to delete temporary file ($dir/my_ls)"
    echo -e "        Try 'sudo ./$me'\033[0m\n"
fi
if ! rm dir/diff; then
    echo -e "\e[31m\033[1m[ERROR] Failed to delete temporary file ($dir/diff)"
    echo -e "        Try 'sudo ./$me'\033[0m\n"
fi
if ! rmdir dir; then
    echo -e "\e[31m\033[1m[ERROR] Failed to delete temporary directory, not empty"
    echo -e "        Please empty it or delete yourself\033[0m\n"
fi

exit 0
