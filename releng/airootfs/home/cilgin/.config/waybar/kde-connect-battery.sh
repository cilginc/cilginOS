#!/bin/bash

# Kimlik Algılama
DEVICE_ID=$(kdeconnect-cli --list-devices | sed -E 's/.*\b([a-zA-Z0-9_]+) \(paired and reachable\).*/\1/')

#Bağlı Mı
# Batarya Seviyesi
BATTERY="$(qdbus org.kde.kdeconnect "/modules/kdeconnect/devices/$DEVICE_ID/battery" org.kde.kdeconnect.device.battery.charge)"
if ! [[ "$BATTERY" =~ ^[0-9]+$ ]]; then
  # Eğer sayı değilse hiçbir şey yapmadan çık
  exit 0
fi
# Şarj Durumu
IS_CHARGING=$(qdbus org.kde.kdeconnect "/modules/kdeconnect/devices/$DEVICE_ID/battery" org.kde.kdeconnect.device.battery.isCharging)

if [ "$IS_CHARGING" == "true" ]; then
  if [ "$BATTERY" -le 10 ]; then
    ICON="󰁺⚡"
  elif [ "$BATTERY" -le 20 ]; then
    ICON="󰁻⚡"
  elif [ "$BATTERY" -le 30 ]; then
    ICON="󰁼⚡"
  elif [ "$BATTERY" -le 40 ]; then
    ICON="󰁽⚡"
  elif [ "$BATTERY" -le 50 ]; then
    ICON="󰁾⚡"
  elif [ "$BATTERY" -le 60 ]; then
    ICON="󰁿⚡"
  elif [ "$BATTERY" -le 70 ]; then
    ICON="󰂀⚡"
  elif [ "$BATTERY" -le 80 ]; then
    ICON="󰂁⚡"
  elif [ "$BATTERY" -le 90 ]; then
    ICON="󰂂⚡"
  elif [ "$BATTERY" -le 100 ]; then
    ICON="󰁹⚡"
  else
    ICON=""
  fi
else
  if [ "$BATTERY" -le 10 ]; then
    ICON="󰁺"
  elif [ "$BATTERY" -le 20 ]; then
    ICON="󰁻"
  elif [ "$BATTERY" -le 30 ]; then
    ICON="󰁼"
  elif [ "$BATTERY" -le 40 ]; then
    ICON="󰁽"
  elif [ "$BATTERY" -le 50 ]; then
    ICON="󰁾"
  elif [ "$BATTERY" -le 60 ]; then
    ICON="󰁿"
  elif [ "$BATTERY" -le 70 ]; then
    ICON="󰂀"
  elif [ "$BATTERY" -le 80 ]; then
    ICON="󰂁"
  elif [ "$BATTERY" -le 90 ]; then
    ICON="󰂂"
  elif [ "$BATTERY" -le 100 ]; then
    ICON="󰁹"
  else
    ICON=""
  fi
fi

echo "$BATTERY% $ICON"
