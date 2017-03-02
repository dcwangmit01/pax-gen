#/bin/bash
set -euo pipefail
# set -x

CWD=`pwd`

# Install dependencies
if ! which qemu-arm-static >/dev/null; then
    echo "Installing build machine dependencies"
    sudo apt-get -yq install quilt qemu-user-static debootstrap kpartx pxz zip bsdtar
fi

# Link the working directory to be somewhere else, not on a vagrant
# shared filesystem.  Otherwise, mknod commands will fail.
#   -h tests for file exists and is symlink
if [ ! -h $CWD/pi-gen/work ] || [ ! -d $HOME/work ] ; then
    # clear out the location since it could be file or dir
    rm -rf $CWD/pi-gen/work

    # create the new location and set the link
    mkdir -p $HOME/work
    ln -s $HOME/work $CWD/pi-gen/work

    # ensure group permissions set to inherit
    chown vagrant:adm $HOME/work
    find $HOME/work -type d -print0 | xargs -0 chmod g+rws
fi


# Link the ./stage2.custom directory into the ./pi-gen directory
if [ ! -h $CWD/pi-gen/stage2.custom ]; then
    # clear out the location since it could be file or dir
    rm -rf $CWD/pi-gen/stage2.custom

    # set the link
    ln -s $CWD/stage2.custom $CWD/pi-gen/stage2.custom
fi


# Configure rax-gen/pi-gen build
#   Skip over stage3 (raspian desktop) and stage4 (NOOB) creation
rm -f $CWD/pi-gen/stage2/EXPORT_NOOBS
rm -f $CWD/pi-gen/stage2/EXPORT_IMAGE
touch $CWD/pi-gen/stage3/SKIP
touch $CWD/pi-gen/stage4/SKIP
rm -f $CWD/pi-gen/stage4/EXPORT_NOOBS
rm -f $CWD/pi-gen/stage4/EXPORT_IMAGE

# Run the build
pushd $CWD/pi-gen
sudo IMG_NAME=pax \
     APT_PROXY=http://192.168.3.12:3142 \
     time ./build.sh 2>&1 | tee build.log
popd
