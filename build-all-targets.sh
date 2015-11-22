#!/bin/bash
VERSION=0.8~exp$(date  '+%Y%m%d%H%M')
OPTIONS="BROKEN=1 DEFAULT_GLUON_RELEASE=$VERSION"
CORES=$(lscpu|grep -e '^CPU(s):'|xargs|cut -d" " -f2)
LOGBASE=/tmp/gluon-build-log-$VERSION
set -x
for ARCH in ar71xx-generic ar71xx-nand mpc85xx-generic x86-generic x86-kvm_guest x86-64 x86-xen_domu; do
  : "################# start building target $ARCH ###########################"
  make -j$CORES GLUON_TARGET=$ARCH $OPTIONS V=s > $LOGBASE$ARCH 2>&1 || break
  # TODO: gzip successfull build before continuing with next target
done && : "#### alle Targets wurden erfolgreich erstellt. ###" || : "Fehlschlag! Abbruch"
set +x
echo "see logfiles in "
echo $LOGBASE*
# watch them during build with: tail -f $LOGBASE*
