#!/bin/bash
# This file is intended to provide some QoL commands for working with Neovim in the Konsole terminal emulator
# Namely, it provides the aliases `n` and `t` which start up Neovim and Tmux respectively in the correct profile with the correct visual settings, and then resets them to previous values upon exit

# It also provides an `nvim-update` command, which updates my Neovim installation since I am running the nightly build


# HELPER FUNCTIONS (can be used as standalone commands in Konsole)
# Pass true/false to these functions to toggle their respective properties. Passing the `-o` flag will return the old value of the property

function profile()
{
    local OPTIND
    while getopts 'o' flag; do
        case "${flag}" in
            o)  dbus-send --dest=$KONSOLE_DBUS_SERVICE $KONSOLE_DBUS_SESSION --print-reply=literal --type=method_call org.kde.konsole.Session.profile | xargs ;;
            ?)  printf "Usage: %s: [-o] true|false\n" $0
                return 2 ;;
        esac
    done
    shift $(($OPTIND - 1))
    dbus-send --dest=$KONSOLE_DBUS_SERVICE $KONSOLE_DBUS_SESSION --type=method_call org.kde.konsole.Session.setProfile string:"$1"
}

function fullscreen()
{
    local OPTIND
    while getopts 'o' flag; do
        case "${flag}" in
            o)  local status=($(dbus-send --dest=$KONSOLE_DBUS_SERVICE /konsole/MainWindow_1 --print-reply=literal --type=method_call org.freedesktop.DBus.Properties.Get string:org.qtproject.Qt.QWidget string:fullScreen | xargs))
                echo ${status[2]} ;;
            ?)  printf "Usage: %s: [-o] true|false\n" $0
                return 2 ;;
        esac
    done
    shift $(($OPTIND - 1))
    dbus-send --dest=$KONSOLE_DBUS_SERVICE /konsole/MainWindow_1 --type=method_call org.kde.konsole.Konsole.MainWindow.viewFullScreen boolean:"$1"
}

# As a side-effect of how this is implemented, passing in something other than "true" or "false" causes the menubar to toggle states
# This includes calling `menubar` with no arguments (or just `menubar -o`)
# All other helper functions in this file simply leave the property unchanged
function menubar()
{
    local OPTIND
    local status=($(dbus-send --dest=$KONSOLE_DBUS_SERVICE /konsole/MainWindow_1/actions/options_show_menubar --print-reply=literal --type=method_call org.freedesktop.DBus.Properties.Get string:org.qtproject.Qt.QAction string:checked | xargs))
    while getopts 'o' flag; do
        case "${flag}" in
            o)  echo ${status[2]} ;;
            ?)  printf "Usage: %s: [-o] true|false\n" $0
                return 2 ;;
        esac
    done
    shift $(($OPTIND - 1))
    if [ "$1" != "${status[2]}" ]; then
        dbus-send --dest=$KONSOLE_DBUS_SERVICE /konsole/MainWindow_1/actions/options_show_menubar --type=method_call org.qtproject.Qt.QAction.trigger
    fi
}

function toolbars()
{
    local OPTIND
    while getopts 'o' flag; do
        case "${flag}" in
            o)  local statusMain=($(dbus-send --dest=$KONSOLE_DBUS_SERVICE /konsole/MainWindow_1 --print-reply=literal --type=method_call org.kde.konsole.KXmlGuiWindow.isToolBarVisible string:mainToolBar | xargs))
                local statusSession=($(dbus-send --dest=$KONSOLE_DBUS_SERVICE /konsole/MainWindow_1 --print-reply=literal --type=method_call org.kde.konsole.KXmlGuiWindow.isToolBarVisible string:sessionToolbar | xargs))
                echo "${statusMain[1]} ${statusSession[1]}" ;;
            ?)  printf "Usage: %s: [-o] true|false true|false\n" $0
                return 2 ;;
        esac
    done
    shift $(($OPTIND - 1))

    local args=($(echo "$*" | xargs))
    dbus-send --dest=$KONSOLE_DBUS_SERVICE /konsole/MainWindow_1 --type=method_call org.kde.konsole.KXmlGuiWindow.setToolBarVisible string:mainToolBar boolean:"${args[0]}"
    dbus-send --dest=$KONSOLE_DBUS_SERVICE /konsole/MainWindow_1 --type=method_call org.kde.konsole.KXmlGuiWindow.setToolBarVisible string:sessionToolbar boolean:"${args[1]}"
}


# MAIN COMMANDS

# By default the command puts the terminal into fullscreen. Pass `-f` to disable this functionality
# NOTE: This does mess with flags intended to be passed to Neovim itself, so just run `nvim` if you need to use flags
# NOTE: All additional behavior disabled if run in tmux, just acts as an alias for `nvim .` (or `nvim [args]` if called with args)
function n()
{
    if [[ "$TERM" != tmux* ]]; then
        local disable_fullscreen_flag=''
        local OPTIND
        while getopts 'f' flag; do
            case "${flag}" in
                f)  disable_fullscreen_flag=1 ;;
                ?)  printf "Usage: %s: [-f] [nvim_args]\n" $0
                    return 2 ;;
            esac
        done
        shift $(($OPTIND - 1))

        local prof=$(profile -o nvim)
        if [ -z "$disable_fullscreen_flag" ]; then
            local full=$(fullscreen -o true)
            local menu=$(menubar -o false)
            local bars=$(toolbars -o false false)
        fi
    fi

    if [ ! -z "$*" ]; then
        nvim $*
    else
        nvim .
    fi

    if [[ "$TERM" != tmux* ]]; then
        profile "$prof"
        if [ -z "$disable_fullscreen_flag" ]; then
            fullscreen "$full"
            menubar "$menu"
            toolbars "$bars"
        fi
    fi
}

# By default the command puts the terminal into fullscreen. Pass `-f` to disable this functionality
# NOTE: This does mess with flags intended to be passed to Tmux itself, so just run `tmux` if you need to use flags
function t()
{
    if [[ "$TERM" == tmux* ]]; then
        printf "Already in tmux\n"
        return 1
    fi

    local disable_fullscreen_flag=''
    local OPTIND
    while getopts 'f' flag; do
        case "${flag}" in
            f)  disable_fullscreen_flag=1 ;;
            ?)  printf "Usage: %s: [-f] [tmux_args]\n" $0
                return 2 ;;
        esac
    done
    shift $(($OPTIND - 1))

    local prof=$(profile -o nvim)
    playerctld daemon > /dev/null 2>&1
    if [ -z "$disable_fullscreen_flag" ]; then
        local full=$(fullscreen -o true)
        local menu=$(menubar -o false)
        local bars=$(toolbars -o false false)
    fi

    if [ ! -z "$*" ]; then
        tmux $*
    else
        tmux
    fi

    profile "$prof"
    pkill playerctld
    if [ -z "$disable_fullscreen_flag" ]; then
        fullscreen "$full"
        menubar "$menu"
        toolbars "$bars"
    fi
}

# Sometimes, especially when developing/testing these commands, changes won't revert properly
# This simply resets things to my preferred defaults
function reset-konsole()
{
    profile "Profile 1"
    fullscreen false
    menubar false
    toolbars true true
}

function nvim-update()
{
    curl -LO https://github.com/neovim/neovim/releases/download/nightly/nvim-linux-x86_64.tar.gz
    sudo rm -rf /usr/local/bin/nvim-linux-x86_64
    sudo tar -C /usr/local/bin -xzvf nvim-linux-x86_64.tar.gz
    rm nvim-linux-x86_64.tar.gz
}

function nvim-update-revert-stable()
{
    curl -LO https://github.com/neovim/neovim/releases/download/stable/nvim-linux-x86_64.tar.gz
    sudo rm -rf /usr/local/bin/nvim-linux-x86_64
    sudo tar -C /usr/local/bin -xzvf nvim-linux-x86_64.tar.gz
    rm nvim-linux-x86_64.tar.gz
}

