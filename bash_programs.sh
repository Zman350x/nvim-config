#!/bin/bash

source ~/.config/nvim/bash_cmds.sh

prof=''
full=''
menu=''
bars=''
disable_fullscreen_flag=''
partial_fullscreen_flag=''

function usage() {
  cat <<EOF
Usage: $(basename "$0") [-f or -p] [args]
EOF
  exit 1
}

while getopts 'fph' flag; do
    case "${flag}" in
        f)  disable_fullscreen_flag=1 ;;
        p)  partial_fullscreen_flag=1 ;;
        h|?)  usage ;;
    esac
done
shift $(($OPTIND - 1))

function _setup_screen()
{
    prof=$(profile -o nvim)
    if [ -n "$partial_fullscreen_flag" ]; then
        menu=$(menubar -o false)
        bars=$(toolbars -o false false)
    elif [ -z "$disable_fullscreen_flag" ]; then
        full=$(fullscreen -o true)
        menu=$(menubar -o false)
        bars=$(toolbars -o false false)
    fi
}

function _reset_screen()
{
    profile "$prof"
    if [ -n "$partial_fullscreen_flag" ]; then
        menubar "$menu"
        toolbars "$bars"
    elif [ -z "$disable_fullscreen_flag" ]; then
        fullscreen "$full"
        menubar "$menu"
        toolbars "$bars"
    fi
}

case "$(basename "$0")" in
    "n")
        if [[ "$TERM" != tmux* ]]; then
            _setup_screen
        fi

        if [ ! -z "$*" ]; then
            nvim $*
        else
            nvim .
        fi

        if [[ "$TERM" != tmux* ]]; then
            _reset_screen
        fi
        ;;

    "t")
        if [[ "$TERM" == tmux* ]]; then
            printf "Already in tmux\n"
            exit 1
        fi

        _setup_screen
        playerctld daemon > /dev/null 2>&1
        if [ ! -z "$*" ]; then
            tmux $*
        else
            tmux
        fi
        pkill playerctld
        _reset_screen
        ;;

    *)
        printf "Invalid command\n"
        ;;
esac
