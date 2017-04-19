#!/bin/bash

# minimal-initramfs by owenthewizard
# package.sh - generate and compress cpio image

set -euo pipefail

source initramfs.conf

printf "Adding files to cpio archive...\n\n"
if [[ -n "${compress}" ]]; then
    (cd initramfs/ && find . -print0 | cpio --quiet --null -ov --format=newc | $compress > ../initramfs.img)
else
    (cd initramfs/ && find . -print0 | cpio --quiet --null -ov --format=newc > ../initramfs.img)
fi

read -n1 -p "Delete build directory? [y/N] " yn
case "${yn}" in
    y|Y)    rm -rf initramfs/;;
esac

printf "\nThanks for using minimal-initramfs!\n"
