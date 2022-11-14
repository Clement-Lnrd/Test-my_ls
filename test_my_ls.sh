#!/bin/bash -e

me=$(basename "${0}")

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
    local options=(
        "Continue anyway"
        "Stop"
    )
    
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
    local diff_stmt=$(diff <(printf '%s\n' "${ls_code}") <(printf '%s\n' "${my_ls_code}"))
    local diff_code=$(echo "${?}")

    echo -e "\e[36m\033[1m//Test #${test_id}\033[0m\033[36m\nls [flags: \"${flags}\" | path: \"${path}\"]"
    if [[ "${diff_code}" = "0" ]]; then
        echo -e "\e[36mAll is good\033[0m"
    fi
    if [[ "${diff_code}" = "1" ]]; then
        echo -e "Outputs are differents:\033[0m"
        echo "${diff_stmt}"
    fi
    if [[ "${diff_code}" = "2" ]]; then
        echo -e "[ERROR] Something went wrong with diff command.\033[0m"
        exit 84
    fi
}

function generate_logs {
    local flags=( "-a" "-r" "-ar" )
    local path=("${HOME}" "${HOME}" "${HOME}")
    local range="${#flags[@]}"

    for (( i=0; i<"${range}"; i++)); do
        echo $(make_test "${flags[${i}]}" "${path[${i}]}" $(( i + 1 )))
        echo ""
    done
}

function main {
    local ascii_header=$(header)
    local option=""

    echo "${ascii_header}"
    if [[ ! $(id -u) = "0" ]]; then
        echo -e "Please relaunch script as sudo, you may run into permissions issues\n"
        option=$(menu)
        if [[ "${option}" = "0" ]]; then
            write_error "error: invalid option ${REPLY}" 84
            exit 84
        fi
        if [[ "${option}" = "2" ]]; then
            echo "Good bye !"
            exit 0
        fi
    fi
    echo "[+] Compiling the my_ls binary."
    make all > /dev/null
    if [[ ! -f "./my_ls" ]]; then
        write_error "Please, move or copy your ${binary} in the same place than ${me}." 84
    fi
    echo "[+] Done"
    echo "[+] Running tests ..."
    generate_logs
    echo "[+] Done !"
    exit 0
}

main
