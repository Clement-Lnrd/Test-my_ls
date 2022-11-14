#!/bin/bash -e

ME=$(basename "${0}")
declare -A ERRORS=(
    [INVALID_OPTION]="Invalid option was provided."
    [MISSING_BINARY]="Put ${ME} in the same folder than my_ls project before running."
)

function header {
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
    #                                Thanks to Ximaz for Contributing                                 #
    #                                                                                                 #
    ###################################################################################################\033[0m\n"
}

function write_error {
    local error="${1}"
    local error_code="${2}"

    echo -e "\e[31m\033[1m[ERROR] ${error}\033[0m\n"
    exit "${error_code}"
}

function menu {
    PS3="Select an option (1-2) : "
    local options=( "Continue anyway" "Stop" )

    select option in "${options[@]}"; do
        case "${REPLY}" in
            "1" | "2")
                echo "${REPLY}"
                break
                ;;
            *)
                echo "0"
                break
                ;;
        esac
    done
}

function make_test {
    local flags="${1}"
    local path="${2}"
    local test_id="${3}"
    local ls_code=$(ls -C $flags $path | tr -s "\t" " ")
    local my_ls_code=$(./my_ls $flags $path)

    echo "${ls_code}" > /tmp/ls_code.tmp
    echo "${my_ls_code}" > /tmp/my_ls_code.tmp
    local diff_code=$(diff /tmp/ls_code.tmp /tmp/my_ls_code.tmp > /tmp/ls_diff.tmp && echo "0" || echo "1")
    echo -e "\e[36m\033[1m//Test #${test_id}\033[0m\033[36m\nls [flags: \"${flags}\" | path: \"${path}\"]"
    if [[ "${diff_code}" = "0" ]]; then
        echo -e "\e[36mAll is good\033[0m"
    fi
    if [[ "${diff_code}" = "1" ]]; then
        echo -e "Outputs are differents:\033[0m"
        cat /tmp/ls_diff.tmp
    fi
}

function generate_logs {
<<<<<<< HEAD
    local flags=( "-a" "-r" "-t" "-d" "-ar" "-R" "-l" "-alRdrt" "-a" "-r" "-t" "-d" "-ar" "-R" "-l" "-alRdrt" )
    local path=("./" "./" "./" "./" "./" "./" "./" "./" "/home/${USERNAME}/" "/home/${USERNAME}/" "/home/${USERNAME}/" "/home/${USERNAME}/" "/home/${USERNAME}/" "/home/${USERNAME}/" "/home/${USERNAME}/" "/home/${USERNAME}/")
    local range="${#flags[@]}"
=======
    local flags=( "-a" "-r" "-ar" "-R")
    local path=( "${HOME}" "/home/${USERNAME}" )
    local flags_range="${#flags[@]}"
    local path_range="${#path[@]}"
>>>>>>> 736e455 (Improving flags and path functionnality, avoiding code repetition, fixing the diff statement)

    for (( i=0; i<"${flags_range}"; i++)); do
        for (( j=0; j<"${path_range}"; j++)); do
            make_test "${flags[${i}]}" "${path[${j}]}" $(( i + 1 + j ))
        done
    done
}

function main {
    local ascii_header=$(header)
    local option=""

    echo "${ascii_header}"
    if [[ ! $(id -u) = "0" ]]; then
        echo -e "Please start the script with sudo, else you may face permissions issues\n"
        option=$(menu)
        [[ "${option}" = "0" ]] && write_error "${ERRORS[INVALID_OPTION]}" 84
        [[ "${option}" = "2" ]] && echo "Good bye !" && exit 0
    fi
    echo "[+] Compiling the my_ls binary."
    make all > /dev/null
    [[ ! -f "./my_ls" ]] && write_error "${ERRORS[MISSING_BINARY]}" 84
    echo "[+] Done"
    echo "[+] Running tests ..."
    generate_logs
    echo "[+] Done !"
    exit 0
}

main
