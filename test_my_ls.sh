#!/bin/bash

# Variables and functions definition

dir=$HOME/.tmp_tests_my_ls
me=`basename "$0"`
PS3='Select an option (1-3): '
options=("Continue, I already running as sudo" "Stop" "Continue anyway (/!\\ WARNING: test risk return everything is good, but that may not be the case /!\\)")

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
echo -e "Please relaunch script as ('./$me') if you are not already, you risk permissions issues\n"
select fav in "${options[@]}"; do
    case $fav in
        "Continue, I already running as sudo")
            break
            ;;
        "Stop")
            exit 0
            ;;
        "Continue anyway (/!\\ WARNING: test risk return everything is good, but that may not be the case /!\\)")
            break
	    break
	    exit
	    ;;
        *) echo "invalid option $REPLY";;
    esac
done
echo ""

# Recompile with Makefile

make re > /dev/null

# Create temporary directory and files for tests

if ! mkdir $dir; then
    echo -e "\e[31m\033[1m[ERROR] Failed to create temporary directory, already exist or permission issue\n        Please delete it, rename in script or relaunch as sudo\033[0m\n"
    exit 84
fi

# Send ls & my_ls outputs in files in the temporary directory

ls $HOME > $dir/ls
./my_ls $HOME > $dir/my_ls
ls -a $HOME > $dir/ls_a
./my_ls -a $HOME > $dir/my_ls_a
ls -r $HOME > $dir/ls_r
./my_ls -r $HOME > $dir/my_ls_r
ls -ar $HOME > $dir/ls_ar
./my_ls -ar $HOME > $dir/my_ls_ar

# Compare outputs

diff $dir/ls $dir/my_ls > $dir/diff
diff $dir/ls_a $dir/my_ls_a > $dir/diff_a
diff $dir/ls_r $dir/my_ls_r > $dir/diff_r
diff $dir/ls_ar $dir/my_ls_ar > $dir/diff_ar
echo -e "\e[36m\033[1m//Test #1\033[0m\033[36m\nls [without OPTION/FILE]"
if [ -s $dir/diff ]; then
    echo -e "Outputs are differents:\033[0m"
    cat $dir/diff
else
    echo -e "\e[36mAll is good\033[0m"
fi
echo ""
echo -e "\e[36m\033[1m//Test #2\033[0m\033[36m\nls -a"
if [ -s $dir/diff_a ]; then
    echo -e "Outputs are differents:\033[0m"
    cat $dir/diff_a
else
    echo -e "\e[36mAll is good\033[0m"
fi
echo ""
echo -e "\e[36m\033[1m//Test #3\033[0m\033[36m\nls -r"
if [ -s $dir/diff_r ]; then
    echo -e "Outputs are differents:\033[0m"
    cat $dir/diff_r
else
    echo -e "\e[36mAll is good\033[0m"
fi
echo ""
echo -e "\e[36m\033[1m//Test #4\033[0m\033[36m\nls -ra"
if [ -s $dir/diff_ar ]; then
    echo -e "Outputs are differents:\033[0m"
    cat $dir/diff_ar
else
    echo -e "\e[36mAll is good\033[0m"
fi

# Delete temporary files & directory

if ! rm -r $dir; then
    echo -e "\e[31m\033[1m[ERROR] Failed to delete temporary directory\n        Please delete it yourself\033[0m\n"
fi

exit 0
