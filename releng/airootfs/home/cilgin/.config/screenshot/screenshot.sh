#!/usr/bin/env bash

SELECTION=$(slurp -d)

grim -g "$SELECTION"

if [ $? == 0 ] ; then
	grim -g "$SELECTION" - | wl-copy
fi
notify-send --icon=$HOME/.config/screenshot/image_proxy.jpg "Screenshot" "Ekran görüntüsü kaydedildi."



