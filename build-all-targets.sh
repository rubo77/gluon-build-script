#!/bin/bash
OPTIONS="BROKEN=1 DEFAULT_GLUON_RELEASE=0.8~exp$(date  '+%Y%m%d%H%M')"
CORES=$(lscpu|grep -e '^CPU(s):'|xargs|cut -d" " -f2)
set -x
for TARGET in ar71xx-generic ar71xx-nand mpc85xx-generic x86-generic x86-kvm_guest x86-64 x86-xen_domu; do
  : "################# $TARGET ###########################"
  echo make -j$CORES GLUON_TARGET=$TARGET $OPTIONS || break 
done && : "#### alle Targets wurden erfolgreich erstellt. ###" || : "Fehlschlag! Abbruch"

