# minimal-initramfs/hooks

This directory holds functions used to enable extra initramfs functionality. Only files with the suffix `.hook` are sourced. Extra files needed by the hook shall be placed in a directory of the same name. Files suffixed by `.files` list files that should be sourced from the machine the initramfs image is being built for or provided by the user.

## base

The `base` hook specifies basic initramfs functions and variables. It should not be disabled.

## fsck

The `fsck` hook specifies that the root filesystem should be fsck'ed before being mounted. By default only the fsck binaries for EXT2/3/4 will be copied. You may edit fsck.files and build.sh to add other filesystems.

## mdev

The `mdev` hook specifies that mdev should be run after mounting `/dev`. Read more on the [BusyBox mdev primer page](https://git.busybox.net/busybox/plain/docs/mdev.txt).

## luks

The `luks` hook specifies that the initramfs should search for and decrypt the luks volume specified by `enc_root` in the kernel command line. Detached headers are supported via the `detached_header` variable in [initramfs.conf](initramfs.conf).

## extra

The `extra` hook adds some extras to the initramfs that are nice to have in case the rescue shell is reached, but aren't needed otherwise.

## colors

The `colors` hook prints colored messages for init output. It also sets the font to according to initramfs.conf.
