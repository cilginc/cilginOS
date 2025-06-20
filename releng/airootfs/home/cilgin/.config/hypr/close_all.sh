#!/usr/bin/env bash
#WorkSpace ID alma

CURRENT_WS=$(hyprctl activeworkspace | grep "workspace" | awk '{print $3}')
PID=$(hyprctl clients | grep -A 8 "workspace: $CURRENT_WS" | grep "pid" | awk '{print $2}')

  #öldürme
for pid in $PID; do
    kill -15 "$pid"
    sleep 0.1
done
