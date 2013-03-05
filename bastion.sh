#!/usr/bin/env bash

##############################################################################
# 
# bastion.sh
#
# Script to automatically harden a Linux system.
#
# GPLv2, Tyler Langlois
#
# Credits:
#   Some functions taken from:
#      https://github.com/chrisnharvey/Easy-Linux-Security
#
##############################################################################

HELPTEXT="$(basename $0) is a script meant to automatically configure many common settings
for a generic Linux installation.

Usage: $0 [-hv]
  -v  verbose
  -h  display this help text"


#####################
# Script entry point.

main() {

  # TODO: Uncomment in prod.
  # [ "${UID}" == "0" ] || death "This program must be run as root.  Exiting."

  # distro_check || death "Unsupported Linux distribution."

  while getopts ":vdh" opt ; do
    case $opt in
      v) VERBOSE=1 ;;
      d) DEBUG=1 ;;
      h) help ;;
    esac
  done

  [ $DEBUG ] && info "Got distro of: $DISTRO"

  ok "Completed $(basename $0)"
}

#################################
# Ensure the distro is supported.
distro_check() {
  if [ -e /etc/redhat-release ]; then
    if [ "`${CAT} /etc/redhat-release | ${AWK} '{ print $1, $2, $3, $7 }'`" = "Red Hat Enterprise 3" ]; then
      DISTRO=RHEL3
    elif [ "`${CAT} /etc/redhat-release | ${AWK} '{ print $1, $2, $3, $7 }'`" = "Red Hat Enterprise 4" ]; then
      DISTRO=RHEL4
    elif [ "`${CAT} /etc/redhat-release | ${AWK} '{ print $1, $3 }' | ${CUT} -d '.' -f1`" = "CentOS 3" ]; then
      DISTRO=CENTOS3
    elif [ "`${CAT} /etc/redhat-release | ${AWK} '{ print $1, $3 }' | ${CUT} -d '.' -f1`" = "CentOS 4" ]; then
      DISTRO=CENTOS4
    elif [ "`${CAT} /etc/redhat-release | ${AWK} '{ print $1, $3 }' | ${CUT} -d '.' -f1`" = "CentOS 5" ]; then
      DISTRO=CENTOS5
    elif [ "`${CAT} /etc/redhat-release | ${AWK} '{ print $1, $2 }'`" = "Fedora Core" ]; then
      DISTRO=FC`${CAT} /etc/redhat-release | ${AWK} '{ print $4 }'`
    elif [ "`${CAT} /etc/redhat-release | ${AWK} '{ print $1, $2 }'`" = "Fedora release" ]; then
      DISTRO=FC`${CAT} /etc/redhat-release | ${AWK} '{ print $3 }'`
    elif [ "`${CAT} /etc/redhat-release | ${AWK} '{ print $1, $2, $5 }'`" = "Red Hat 9" ]; then
      DISTRO=RH9
    elif [ "`${CAT} /etc/redhat-release | ${AWK} '{ print $1, $2, $5 }' | ${CUT} -d '.' -f1`" = "Red Hat 7" ]; then
      DISTRO=RH7
    fi
  elif [ -e /etc/debian_version ]; then
    if [ "`${CAT} /etc/debian_version`" = "3.1" ] || [ "`${CAT} /etc/debian_version`" = "3.0" ]; then
      DISTRO=DEBIAN3
    fi
  elif [ ! -e /etc/redhat-release ] || [ ! -e /etc/debian_version ]; then
    return 1
  fi
  return 0
}

info()  { echo $'[\e[1;36m info \e[0m]' $@ ; }
ok()    { echo $'[\e[1;32m  ok  \e[0m]' $@ ; }
error() { echo $'[\e[1;31m err  \e[0m]' $@ ; }
warn()  { echo $'[\e[1;33m warn \e[0m]' $@ ; }

death() {
  error $@
  exit 1
}

silence() { (($@) 2>&1) > /dev/null ; }

help() { echo "$HELPTEXT" ; exit 0 ; }

main $@

