#/bin/bash
set -euo pipefail
# set -x

CWD=`pwd`

# Setup the configuration file
PI_CONF=$CWD/pi-gen/config
echo "IMG_NAME=pax" > $PI_CONF
echo "APT_PROXY=http://192.168.3.12:3142" >> $PI_CONF

# Copy the custom files over to pi-gen.
#   Cannot be softlinks, since this in turn is copied inside of docker image
#   used for building
rm -rf $CWD/pi-gen/stage2.custom
cp -r  $CWD/stage2.custom $CWD/pi-gen/stage2.custom

# The ./docker directory is optionally populated by a docker-compose.yaml file
# and *.docker.tar.gz files which are images created by "docker save".  If this
# directory exists then we will load the images and docker-compose.yaml onto
# the pax image.  See ./stage2.custom/01-tweaks/00-run.sh
mkdir -p $CWD/docker
cp -r  $CWD/docker $CWD/pi-gen/stage2.custom/01-tweaks

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
