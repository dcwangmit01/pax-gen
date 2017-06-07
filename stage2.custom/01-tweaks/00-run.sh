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

# Enable auto-login of user pi, with the existing auto-login script
#   We are reusing the raspbian-created file.  If this file disappears in the
#     future, do it manually with these instructions:
#   https://unix.stackexchange.com/questions/42359/how-can-i-autologin-to-desktop-with-systemd
#   https://stackoverflow.com/questions/33753985/raspberry-pi-auto-login-without-etc-inittab
# The .xsession is installed later in the user loop
ln -sf /etc/systemd/system/autologin@.service \
    /etc/systemd/system/getty.target.wants/getty@tty1.service

EOF

# Setup the /boot/config.txt by appending the custom one
boot_config=${ROOTFS_DIR}/boot/config.txt
if [ -f $boot_config ] ; then
    # Truncates the Custom part of the config and below
    sed -n '/## Custom:/q;p' -i $boot_config
    # Appends custom boot_config
    cat ./files/boot_config.txt >> $boot_config
fi

# Install the docker images, docker-compose.yaml, etc
install -o root -m 755 -d ${ROOTFS_DIR}/opt/docker/bin
install -o root -m 755 -d ${ROOTFS_DIR}/opt/docker/images
for _file in docker/*.docker.tar.gz; do
    install -o root -m 644 $_file ${ROOTFS_DIR}/opt/docker/images/
done
install -o root -m 644 docker/docker-compose.yaml ${ROOTFS_DIR}/opt/docker/
install -o root -m 755 files/docker_run.sh ${ROOTFS_DIR}/opt/docker/bin/
# Set the docker script to autostart via rc.local

# Install iptables rules
install -o root -m 755 -d ${ROOTFS_DIR}/opt/iptables
install -o root -m 755 files/iptables_rules.sh ${ROOTFS_DIR}/opt/iptables/

# Install /etc/rc.local
rc_local=${ROOTFS_DIR}/etc/rc.local
if [ -f $rc_local ] ; then
    # Truncates the Custom part of the config and below
    sed -n '/## Custom:/q;p' -i $rc_local
    # Comment out any existing "exit 0" lines
    sed 's/^exit/# exit/' -i $rc_local
    # Appends custom rc_local
    cat ./files/rc.local >> $rc_local
fi

#####################################################################
# For each user
#####################################################################

declare -A owner_to_home
owner_to_home=( \
    ["root"]="root" \
    ["1000"]="home/pi" )
for owner in "${!owner_to_home[@]}"; do
    home=${owner_to_home[$owner]}

    # install ssh authorized keys
    install -o $owner -m 755 -d ${ROOTFS_DIR}/$home/.ssh/
    install -o $owner -m 644 files/authorized_keys ${ROOTFS_DIR}/$home/.ssh/

    # Setup the .bashrc by appending the custom one
    bashrc=${ROOTFS_DIR}/$home/.bashrc
    if [ -f $bashrc ] ; then
        # Truncates the Custom part of the config and below
        sed -n '/## Custom:/q;p' -i $bashrc
        # Appends custom bashrc
        cat ./files/dot.bashrc >> $bashrc
        # ensure ownership
        chown $owner:$owner $bashrc
    fi

    # Set configuration files for common utilities
    install -o $owner -m 644 files/dot.screenrc ${ROOTFS_DIR}/$home/.screenrc
    install -o $owner -m 644 files/dot.emacs ${ROOTFS_DIR}/$home/.emacs

    # Set configuration files for X11
    install -o $owner -m 644 files/dot.xsession ${ROOTFS_DIR}/$home/.xsession
done
