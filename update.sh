#!/usr/bin/env bash

PACKAGES="cbonsai \
rose-pine-cursor \
wlogout \
yay \
zen-browser-bin"

get_packages() {
  yay -G $PACKAGES
}

make_packages() {
  for packet in $PACKAGES; do
    cd "$packet" || exit
    runuser --user nobody -- makepkg --clean -s --skipchecksums --skipinteg
    mv ./*.pkg.tar.zst
    cd ..
    rm -rf $packet
  done
}

add_packages() {
  repo-add localrepo.db.tar.zst ./*pkg.tar.zst
  find . -type f -name "*.old" -delete
}

main() {
  get_packages
  make_packages
  add_packages
  find . -type f -name "*debug*" -delete
}

main
