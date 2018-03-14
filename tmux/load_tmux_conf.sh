#!/bin/bash

load_tmux_version () {
    tmux_version="$(tmux -V | cut -c 6-)"
    if [[ $(echo "$tmux_version >= 2.1" | bc) -eq 1 ]] ; then
        tmux source-file "${HOME}/.tmux_post_2.1.conf"
    else
        tmux source-file "${HOME}/.tmux_pre_2.1.conf"
    fi
}

load_tmux_version
