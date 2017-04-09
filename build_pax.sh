#/bin/bash
set -euo pipefail
# set -x

CWD=`pwd`

# Setup the configuration file
PI_CONF=$CWD/pi-gen/config
echo "IMG_NAME=pax" >> $PI_CONF
echo "APT_PROXY=http://192.168.3.12:3142" >> $PI_CONF

# Copy the custom files over to pi-gen.
#   Cannot be softlinks, since this in turn is copied inside of docker image
rm -rf $CWD/pi-gen/stage2.custom
cp -r  $CWD/stage2.custom $CWD/pi-gen/stage2.custom

# Configure rax-gen/pi-gen build
#   Skip over stage3 (raspian desktop) and stage4 (NOOB) creation
rm -f $CWD/pi-gen/stage2/EXPORT_NOOBS
rm -f $CWD/pi-gen/stage2/EXPORT_IMAGE
touch $CWD/pi-gen/stage3/SKIP
touch $CWD/pi-gen/stage4/SKIP
touch $CWD/pi-gen/stage5/SKIP

# Run the build (pi-gen requires root)
pushd $CWD/pi-gen
docker rm -f pigen_work 2>&1 > /dev/null || true
time ./build-docker.sh 2>&1 | tee build.log
popd
