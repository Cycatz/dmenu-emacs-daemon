#!/bin/bash

set -e

kill_server()
{
    local SERVER_DIR="/run/user/1000/emacs/"

    usage()
    {
        cat <<EOT
Usage '$0 kill':
- -d <dir> or --server-dir <dir>
  - Specify the directory where Emacs server sockets live, default is '$SERVER_DIR'.
EOT
        exit 1
    }

    while [[ $# -gt 0 ]]; do
        case "$1" in 
            -d|--server-dir   ) shift; SERVER_DIR="$1";;
            -h|--help         ) usage;;
            *                 ) usage;;  
        esac
        shift
    done

    local -a sockets
    local socket_name

    mapfile -t sockets < <(command ls -1 "$SERVER_DIR")

    socket_name=$(printf '%s\n' "${sockets[@]}" | rofi -dmenu -p "Select the server")
    socket_path="${SERVER_DIR}${socket_name}"

    emacsclient --eval '(kill-emacs)' --socket-name="$socket_path"
}

start_client()
{

    local SERVER_DIR="/run/user/1000/emacs/"
    local DEFAULT_DAEMON_NAME="default"
    local DISPLAY_MODE="graphical" 

    usage()
    {
        cat <<EOT
Usage '$0 start':
- -d <dir> or --server-dir <dir>
  - Specify the directory where Emacs server sockets live, default is '$SERVER_DIR'.
- -n <name> or --daemon-name <name>
  - Specify the default Emacs server daemon name, default is '$DEFAULT_DAEMON_NAME'.    
- -t, -nw,  --tty
  - Create the client frame on the current terminal
EOT
        exit 1
    }

    while [[ $# -gt 0 ]]; do
        case "$1" in 
            -d|--server-dir   ) shift; SERVER_DIR="$1";;
            -n|--default-name ) shift; DEFAULT_DAEMON_NAME="$1";;
            -t|-nw|--tty      ) DISPLAY_MODE="tty";;
            -h|--help         ) usage;;
            *                 ) usage;;  
        esac
        shift
    done

    local -a sockets
    local socket_name

    mapfile -t sockets < <(command ls -1 "$SERVER_DIR")
    sockets+=("<customize>")

    socket_name=$(printf '%s\n' "${sockets[@]}" | rofi -dmenu -p "Select the server")

    if [[ "$socket_name" == "<customize>" ]]; then
        socket_name=$(rofi -dmenu -p "Enter the daemon name")
    fi

    socket_path="${SERVER_DIR}${socket_name}"

    if [[ "$DISPLAY_MODE" == "tty" ]]; then  
        emacsclient -t -c --socket-name="$socket_path" -a ""
    else
        emacsclient -c --socket-name="$socket_path" -a ""
    fi
}


usage()
{
    cat <<EOT
Usage '$0':
- start: Choose the Emacs server and start the client to communicate it.
- kill:  Choose the Emacs server to kill.
EOT
    exit 1
}

main()
{
    if [[ $# -eq 0 ]]; then
        usage
    fi

    case "$1" in
        start ) shift; start_client "$@";;
        kill  ) shift; kill_server "$@";;
        help  ) usage;;
        *     ) usage;;
    esac
}


main "$@"
