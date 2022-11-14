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
    local diff_stmt=$(diff <(echo "${ls_code}") <(echo "${my_ls_code}"))
    local diff_code=$(echo "${?}")

    echo -e "\e[36m\033[1m//Test #${test_id}\033[0m\033[36m\nls [flags: \"${flags}\" | path: \"${path}\"]"
    [[ "${diff_code}" = "0" ]] && echo -e "\e[36mAll is good\033[0m"
    [[ "${diff_code}" = "1" ]] && echo -e "Outputs are differents:\033[0m" && echo "${diff_stmt}"
    [[ "${diff_code}" = "2" ]] && echo -e "[ERROR] Something went wrong with diff command.\033[0m" && exit 84
}

function generate_logs {
    local flags=( "-a" "-r" "-ar" )
    local path=("${HOME}" "${HOME}" "${HOME}")
    local range="${#flags[@]}"

    for (( i=0; i<"${range}"; i++)); do echo $(make_test "${flags[${i}]}" "${path[${i}]}" $(( i + 1 ))); done
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
