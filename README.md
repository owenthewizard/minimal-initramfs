# This project sucks. Don't use it.

# minimal-initramfs

`minimal-initramfs` is a set of bash scripts to create a functional and minimal initial ram filesystem (initramfs). It uses a hook system to enable or disable functions modularly.

## Usage

1. Edit initramfs.conf

`${EDITOR} initramfs.conf`

2. Build the initramfs directory

`./build.sh`

3. Compress it into a cpio image

`./package.sh`

Your initramfs is now located at initramfs.img.
