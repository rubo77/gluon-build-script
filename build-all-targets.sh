#!/bin/bash

# builds all 7 targets for gluon
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
VERSION=0.8~exp$(date '+%Y%m%d%H%M')

# Folder to deploy the built images
ARCHIVE=/var/www/freifunk/firmware/ffki

# logs start and enddate
LOGFILE=/tmp/gluon-build-log-$VERSION

# Options for make
OPTIONS="BROKEN=1 DEFAULT_GLUON_RELEASE=$VERSION"

if [[ $EUID -eq 0 ]]; then 
	echo "cannot be run as root"
	exit
fi

# detect amount of CPU cores
CORES=$(lscpu|grep -e '^CPU(s):'|xargs|cut -d" " -f2)

# ensure archive folder exists for this version
mkdir -p $ARCHIVE/$VERSION

MESSAGE= "When done, move images into archive with
rsync -a --info=progress2 output/images/ $ARCHIVE/$VERSION/
rm -Rf output/images

logfiles: $LOGFILE\*"
echo $MESSAGE

set -x
#for ARCH in ar71xx-generic ar71xx-nand mpc85xx-generic x86-generic x86-kvm_guest x86-64 x86-xen_domu; do
for ARCH in ar71xx-generic x86-generic mpc85xx-generic; do
  trap ": user abort; exit;" SIGINT SIGTERM # so CTRL+C will exit the loop
  echo "################# $(date) start building target $ARCH ###########################" >> $LOGFILE
  make -j$CORES GLUON_TARGET=$ARCH $OPTIONS V=s || exit 1
  # TODO: gzip successfull build before continuing with next target
done && : "all targets created in folder output/images/"
set +x

echo "################# $(date) finished script ###########################" >> $LOGFILE
cat $LOGFILE
echo $MESSAGE
