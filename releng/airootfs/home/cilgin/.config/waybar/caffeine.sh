#!/usr/bin/env bash

if pgrep -x "hypridle" > /dev/null; then
    pkill hypridle
else
    hyprctl dispatch exec hypridle > /dev/null
fi
