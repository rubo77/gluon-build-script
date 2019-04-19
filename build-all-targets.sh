#!/bin/bash

# builds all 7 targets for gluon (disk space needed: ~ 7 GB each)
#
# Install:
#
# sudo apt-get install git make gcc g++ unzip libncurses5-dev zlib1g-dev subversion gawk bzip2 libssl-dev
# git clone https://github.com/freifunk-gluon/gluon.git
# cd gluon
# # adapt your site/
# make update
# ./build-all-targets.sh
#
# tip: call this script through ccze: `./build-all-targets.sh | ccze -A `

# Configuration

# version for your build
VERSION=2018.2.0~exp$(date '+%Y%m%d%H%M')

# Folder to deploy the built images
ARCHIVE=/var/www/freifunk/firmware/ffki

# logs start and enddate
LOGFILE=/tmp/gluon-build-log-$VERSION

BUILD_BROKEN="BROKEN=1"
# or BUILD_BROKEN=""
T="ar71xx-generic ar71xx-tiny ar71xx-nand brcm2708-bcm2708 brcm2708-bcm2709 mpc85xx-generic ramips-mt7621 sunxi-cortexa7 x86-generic x86-geode x86-64 ipq40xx ramips-mt7620 ramips-mt76x8 ramips-rt305x"
if [ $BROKEN != "" ] ; then
  T="$T ar71xx-mikrotik brcm2708-bcm2710 ipq806x mvebu-cortexa9"
fi

# Options for make
OPTIONS="$BUILD_BROKEN DEFAULT_GLUON_RELEASE=$VERSION"

if [[ $EUID -eq 0 ]]; then 
  echo "cannot be run as root"
  exit
fi

# detect amount of CPU cores
#CORES=$(lscpu|grep -e '^CPU(s):'|xargs|cut -d" " -f2)
CORES=1

# ensure archive folder exists for this version
mkdir -p $ARCHIVE/$VERSION

MESSAGE="When done, move images into archive with
rsync -a --info=progress2 output/images/ $ARCHIVE/$VERSION/
rm -Rf output/images

logfiles: $LOGFILE\*"
echo $MESSAGE

start_timestamp=$(date +%s)
set -x
for TARGET in $T; do
  start=$(date +%s)
  trap ": user abort; exit;" SIGINT SIGTERM # so CTRL+C will exit the loop
  echo "################# $(date) start building target $TARGET ###########################" >> $LOGFILE
  make -j$CORES GLUON_TARGET=$TARGET $OPTIONS V=s || exit 1
  # TODO: gzip successfull build before continuing with next target
  echo "Zeit seit Start: "$((($(date +%s)-$start_timestamp)/60))":"$((($(date +%s)-$start_timestamp)%60))" Minuten"
  M="Zeit $TARGET: "$((($(date +%s)-$start)/60))":"$((($(date +%s)-$start)%60))" Minuten"
  MESSAGE=$MESSAGE" "$M
  let i++
done && : "all targets created in folder output/images/"
set +x
echo -n "finished: "; date

echo "################# $(date) finished script ###########################" >> $LOGFILE
cat $LOGFILE
echo $MESSAGE
