#!/bin/bash

# minimal-initramfs by owenthewizard
# build.sh - copy files and directory structure for initramfs

source initramfs.conf

copy_files()
{
    local counter=0
    declare -a needed
    while read -r line; do
        copy_prog "${line}" || needed[$counter]="${line}"
        ((counter++))
    done < hooks/"${1}".files
    if [[ -n "${needed[*]}" ]]; then
        printf "These files need to be supplied to initramfs/ manually:\n"
        echo "${needed[@]}" | tr ' ' '\n'
        echo
    fi
}

copy_prog()
{
    path="${1#usr/}"
    path="${path%/*}"
    prog="${1##*/}"

    if ( ldd "/${1}" &> /dev/null ); then
        for lib in $(ldd "/${1}" | grep -F /lib | cut -d'(' -f1 | cut -d'>' -f2); do
            cp -Ln "${lib}" "initramfs/lib64/"
            #chmod 755 "initramfs${lib}"
        done
    fi
    cp -L "/${1}" "initramfs/${path}/${prog}" 2> /dev/null || return 1
    #chmod 755 "initramfs/${path}/${prog}"
}

printf "Creating directories...\n"
echo
mkdir -p initramfs/{bin,dev,etc/terminfo/l,lib64,mnt/root,proc,root,sbin,sys}

for hook in ${hooks[@]}; do
    case "${hook}" in
        base)   printf "Adding hook: base\n\n"
                cp -r hooks/base/* initramfs/
                copy_files "base";;
        extra)  printf "Adding hook: extra\n\n"
                copy_files "extra";;
        luks)   printf "Adding hook: luks\n\n"
                header_uuid=""
                if [[ -f "${detached_header}" ]]; then
                    cp "${detached_header}" initramfs/luks.header
                    echo 'detached_header=/luks.header' >> initramfs/functions.sh
                elif [[ -b "${detached_header}" ]]; then
                    header_uuid="$(blkid ${detached_header} -o export -s UUID | grep -Eo '[0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{12}')"
                    echo 'detached_header="$(findfs UUID='"${header_uuid}"')"' >> initramfs/functions.sh
                fi
                copy_files "luks";;
        fsck)   printf "Adding hook: fsck\n\n"
                copy_files "fsck"
                (cd initramfs/sbin/ && ln -s e2fsck fsck.ext2
		    ln -s e2fsck fsck.ext3
		    ln -s e2fsck fsck.ext4);;
        mdev)   printf "Adding hook: mdev\n\n"
                copy_files "mdev";;
        colors) printf "Adding hook: colors\n\n"
		copy_files "colors"
		if [[ -n "${font}" ]]; then
		    cp "${font}" initramfs/etc/font
		fi;;
    esac
    printf "Regenerating init functions...\n"
    echo
    grep -Ev '^$|^#' hooks/"${hook}.hook" >> initramfs/functions.sh 2> /dev/null
done

printf "Adding missing functions to init...\n"
if [[ ! " ${hooks[*]} " =~ " colors " ]]; then
    cat >> initramfs/functions.sh <<EOF
print_info()
{
    printf "${1}\n"
}
print_error()
{
    printf "${1}\n"
}
print_warn()
{
    printf "${1}\n"
}
EOF
fi
if [[ ! " ${hooks[*]} " =~ " mdev " ]]; then
    cat >> initramfs/functions.sh <<EOF
task_mdev()
{
    return 0
}
EOF
fi
if [[ ! " ${hooks[*]} " =~ " luks " ]]; then
    cat >> initramfs/functions.sh <<EOF
task_luks()
{
    return 0
}
EOF
fi
if [[ ! " ${hooks[*]} " =~ " fsck " ]]; then
    cat >> initramfs/functions.sh <<EOF
task_fsck()
{
    return 0
}
EOF
fi
if [[ ! " ${hooks[*]} " =~ " colors " ]]; then
    cat >> initramfs/functions.sh << EOF
set_font()
{
    return 0
}
EOF
fi

printf "To finish generating your initramfs run package.sh\n"
