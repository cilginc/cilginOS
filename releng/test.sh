#!/bin/bash

# Kullanım: ./generate_profiledef.sh /hedef/klasor

target_dir="$1"

if [[ ! -d "$target_dir" ]]; then
    echo "Kullanım: $0 /path/to/dir"
    exit 1
fi

# Tüm dosyaları tara ve 644 olmayanları bul
find "$target_dir" -type f ! -perm 644 | while read -r file; do
    # UID, GID ve permissionları al
    read uid gid perm < <(stat -c "%u %g %a" "$file")
    echo "[\"$file\"]=\"$uid:$gid:$perm\""
done
