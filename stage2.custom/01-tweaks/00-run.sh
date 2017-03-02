#!/bin/bash
set -euo pipefail
set -x


declare -A owner_to_home
owner_to_home=( \
    ["root"]="/root" \
    ["1000"]="/home/pi" )
for owner in "${!owner_to_home[@]}"; do
    home=${owner_to_home[$owner]}

    # install ssh authorized keys
    install -o $owner -m 755 -d ${ROOTFS_DIR}$home/.ssh/
    install -o $owner -m 644 files/authorized_keys ${ROOTFS_DIR}$home/.ssh/

    bashrc=${ROOTFS_DIR}$home/.bashrc
    # Setup the .bashrc by appending the custom one
    if [ -f $bashrc ] ; then
	# Truncates the Custom part of the config and below
	sed -n '/## Custom:/q;p' -i $bashrc
	# Appends custom bashrc
	cat ./files/dot.bashrc >> $bashrc
	# ensure ownership
	chown $owner:$owner $bashrc
    fi

    # Set configuration files for common utilities
    install -o $owner -m 644 files/dot.screenrc ${ROOTFS_DIR}$home/.screenrc
    install -o $owner -m 644 files/dot.emacs ${ROOTFS_DIR}$home/.emacs
done

on_chroot <<EOF

# fix the locales to be US
if ! locale |grep en_US /dev/null; then
    # Enable the en_US locale for generation
    sed -i 's@# en_US.UTF-8 UTF-8@en_US.UTF-8 UTF-8@' /etc/locale.gen
    # generate locales
    locale-gen
    # update the default locale
    update-locale LANG="en_US.UTF-8"
fi

# enable sshd if it isn't already
if ! -e /etc/rc2.d/S02ssh; then
    systemctl enable ssh
fi

# set the default keyboard layout to US
sed -i 's@XKBLAYOUT=.*@XKBLAYOUT=\"us\"@' /etc/default/keyboard

# install docker
if ! which docker; then
    curl -sSL https://get.docker.com | sh
    usermod -aG docker pi
fi

EOF

