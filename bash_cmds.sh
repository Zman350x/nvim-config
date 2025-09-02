#!/bin/bash
# This file is intended to provide some QoL commands for working with Neovim/tmux in the Konsole terminal emulator

# It also provides an `nvim-update` command, which updates my Neovim installation since I am running the nightly build

# Pass true/false to these functions to toggle their respective properties. Passing the `-o` flag will return the old value of the property

function profile()
{
    local OPTIND
    while getopts 'oh' flag; do
        case "${flag}" in
            o)    dbus-send --dest=$KONSOLE_DBUS_SERVICE $KONSOLE_DBUS_SESSION --print-reply=literal --type=method_call org.kde.konsole.Session.profile | xargs ;;
            h|?)  printf "Usage: %s: [-o] <profile name>\n" $0
                  return 1 ;;
        esac
    done
    shift $(($OPTIND - 1))
    dbus-send --dest=$KONSOLE_DBUS_SERVICE $KONSOLE_DBUS_SESSION --type=method_call org.kde.konsole.Session.setProfile string:"$1"
}

function fullscreen()
{
    local OPTIND
    while getopts 'oh' flag; do
        case "${flag}" in
            o)    local status=($(dbus-send --dest=$KONSOLE_DBUS_SERVICE /konsole/MainWindow_1 --print-reply=literal --type=method_call org.freedesktop.DBus.Properties.Get string:org.qtproject.Qt.QWidget string:fullScreen | xargs))
                  echo ${status[2]} ;;
            h|?)  printf "Usage: %s: [-o] true|false\n" $0
                  return 1 ;;
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
    while getopts 'oh' flag; do
        case "${flag}" in
            o)    echo ${status[2]} ;;
            h|?)  printf "Usage: %s: [-o] true|false\n" $0
                  return 1 ;;
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
    while getopts 'oh' flag; do
        case "${flag}" in
            o)    local statusMain=($(dbus-send --dest=$KONSOLE_DBUS_SERVICE /konsole/MainWindow_1 --print-reply=literal --type=method_call org.kde.konsole.KXmlGuiWindow.isToolBarVisible string:mainToolBar | xargs))
                  local statusSession=($(dbus-send --dest=$KONSOLE_DBUS_SERVICE /konsole/MainWindow_1 --print-reply=literal --type=method_call org.kde.konsole.KXmlGuiWindow.isToolBarVisible string:sessionToolbar | xargs))
                  echo "${statusMain[1]} ${statusSession[1]}" ;;
            h|?)  printf "Usage: %s: [-o] true|false true|false\n" $0
                  return 2 ;;
        esac
    done
    shift $(($OPTIND - 1))

    local args=($(echo "$*" | xargs))
    dbus-send --dest=$KONSOLE_DBUS_SERVICE /konsole/MainWindow_1 --type=method_call org.kde.konsole.KXmlGuiWindow.setToolBarVisible string:mainToolBar boolean:"${args[0]}"
    dbus-send --dest=$KONSOLE_DBUS_SERVICE /konsole/MainWindow_1 --type=method_call org.kde.konsole.KXmlGuiWindow.setToolBarVisible string:sessionToolbar boolean:"${args[1]}"
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

