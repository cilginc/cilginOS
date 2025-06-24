#!/bin/bash

target_dir="$1"

if [[ ! -d "$target_dir" ]]; then
    echo "Usage: $0 /path/to/dir"
    exit 1
fi

find "$target_dir" -type f ! -perm 644 | while read -r file; do
    # Get UID, GID and permissionları
    read uid gid perm < <(stat -c "%u %g %a" "$file")
    echo "[\"$file\"]=\"$uid:$gid:$perm\""
done
