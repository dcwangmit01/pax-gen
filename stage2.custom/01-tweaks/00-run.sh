#!/bin/bash
set -euo pipefail
set -x

#####################################################################
# For the system
#####################################################################

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

# set the default keyboard layout to US
sed -i 's@XKBLAYOUT=.*@XKBLAYOUT=\"us\"@' /etc/default/keyboard

# enable sshd if it hasn't been already
if [[ ! -e /etc/rc2.d/S02ssh ]]; then
    systemctl enable ssh
fi

# install docker
if ! which docker; then
    curl -fsSL https://get.docker.com/ | sh
    usermod -aG docker root
    usermod -aG docker pi
fi

# Install docker-compose
if ! which docker-compose; then
    pip install -U docker-compose
fi

EOF

# Setup the /boot/config.txt by appending the custom one
boot_config=${ROOTFS_DIR}/boot/config.txt
if [ -f $boot_config ] ; then
    # Truncates the Custom part of the config and below
    sed -n '/## Custom:/q;p' -i $boot_config
    # Appends custom boot_config
    cat ./files/boot_config.txt >> $boot_config
fi

# Enable auto-login of user pi, with the existing auto-login script
#   We are reusing the raspbian-created file.  If this file disappears in the
#     future, do it manually with these instructions:
#   https://unix.stackexchange.com/questions/42359/how-can-i-autologin-to-desktop-with-systemd
#   https://stackoverflow.com/questions/33753985/raspberry-pi-auto-login-without-etc-inittab
on_chroot <<EOF

ln -sf /etc/systemd/system/autologin@.service \
  /etc/systemd/system/getty.target.wants/getty@tty1.service

EOF
# The .xsession is installed later in the user loop

#######################################
# Install the docker images, docker-compose.yaml, and set to autostart
#######################################

# Create the directory can copy over the images and docker-compose.yaml
install -o root -m 755 -d ${ROOTFS_DIR}opt/docker
for file in ./docker/*; do
    echo "$file"
    install -o root -m 644 "$file" ${ROOTFS_DIR}opt/docker
done

if [ -f ${ROOTFS_DIR}opt/docker/docker-compose.yaml ]; do
    echo "@reboot docker-compose -f /opt/docker/docker-compose.yaml up -d" \
	 > ${ROOTFS_DIR}/etc/cron.d/docker
    chown root:root ${ROOTFS_DIR}/etc/cron.d/docker
    chmod 644 ${ROOTFS_DIR}/etc/cron.d/docker
fi

on_chroot <<EOF

for file in /opt/docker/*.docker.tar.gz; do
  echo "$file"
  zcat "$file" | docker load
done

EOF

#####################################################################
# For each user
#####################################################################

declare -A owner_to_home
owner_to_home=( \
    ["root"]="/root" \
    ["1000"]="/home/pi" )
for owner in "${!owner_to_home[@]}"; do
    home=${owner_to_home[$owner]}

    # install ssh authorized keys
    install -o $owner -m 755 -d ${ROOTFS_DIR}$home/.ssh/
    install -o $owner -m 644 files/authorized_keys ${ROOTFS_DIR}$home/.ssh/

    # Setup the .bashrc by appending the custom one
    bashrc=${ROOTFS_DIR}$home/.bashrc
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

    # Set configuration files for X11
    install -o $owner -m 644 files/dot.xsession ${ROOTFS_DIR}$home/.xsession
done
