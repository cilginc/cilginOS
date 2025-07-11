#!/usr/bin/env bash

PACKAGES="cbonsai rose-pine-cursor wlogout yay zen-browser-bin"

get_packages() {
  for packet in $PACKAGES; do
    git clone https://aur.archlinux.org/${packet}.git
  done
}

make_packages() {
  for packet in $PACKAGES; do
    cd $packet || exit
    runuser --user cilgin -- makepkg --clean -s --skipchecksums --skipinteg --noconfirm
    mv ./*.pkg.tar.zst ..
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
  chown -R cilgin:cilgin .
  make_packages
  add_packages
  find . -type f -name "*debug*" -delete
}

main
