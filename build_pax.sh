#/bin/bash
set -euo pipefail
# set -x

CWD=`pwd`
WORK_DIR="$HOME/work"

# Setup the configuration file
PI_CONF=$CWD/pi-gen/config
echo "WORK_DIR=$WORK_DIR" > $PI_CONF
echo "DEPLOY_DIR=$CWD/deploy" >> $PI_CONF
echo "IMG_NAME=pax" >> $PI_CONF
echo "APT_PROXY=http://192.168.3.12:3142" >> $PI_CONF

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

# Run the build (pi-gen requires root)
pushd $CWD/pi-gen
sudo ./build.sh 2>&1 | tee build.log
popd
