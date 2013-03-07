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

Usage: $0 [-acvdh]
  -a  automatically run (assume defaults)
  -v  verbose
  -d  enable debugging output
  -h  display this help text"

CAT="$(which cat)"
AWK="$(which awk)"
CUT="$(which cut)"
GREP="$(which grep)"

#####################
# Script entry point.

main() {

  # TODO: Uncomment in prod.
  # [ "${UID}" == "0" ] || death "This program must be run as root.  Exiting."

  distro_check || death "Unsupported Linux distribution."

  while getopts ":acvdh" opt ; do
    case $opt in
      a) AUTO=1 ;;
      v) VERBOSE=1 ;;
      d) DEBUG=1 ;;
      h) help ;;
    esac
  done

  [ $DEBUG ] || [ $VERBOSE ] && info "Got distro of: $DISTRO"

  for script in ./tasks/* ; do
    [ -x $script ] || continue

    TASK="$(basename $script | \
      sed 's/^[^a-zA-Z]*\([a-zA-Z]\{1,\}\)[.][a-z]\{1,\}$/\1/')"

    source $script

    prevalidate $TASK task_precheck || continue

    if [ ! ${AUTO} ] ; then
      info "${TASK} wants to execute:\n\t\t$(task_explain)"
      if ! confirm ; then
        info "Skipping ${TASK}"
        continue
      fi
    fi

    if task_run ; then
      ok ${TASK}
    else
      error "${TASK} could not complete. See any preceding errors."
    fi

  done

  ok "Completed $(basename $0)"
}

prevalidate() {
  CHECK_INFO="$($2)"
  RET=$?

  if [ "${RET}" = 0 ] ; then
    return 0
  elif [ "${RET}" = 1 ] ; then
    info "${CHECK_INFO}, skipping ${1}"
    return 1
  elif [ "${RET}" = 2 ] ; then
    warn "${CHECK_INFO}"
    return 0
  else
    error "${CHECK_INFO}, skipping ${1}"
    return 1
  fi
}

###########################
# Confirm a step
confirm() {
  query "Proceed? (y/n): "
  read PROCEEDASK

  until [ "${PROCEEDASK}" = "y" ] || [ "${PROCEEDASK}" = "n" ]; do
    query "Please enter 'y' or 'n': "
    read PROCEEDASK
  done

  if [ ${PROCEEDASK} = "n" ] ; then
    return 1
  else
    return 0
  fi
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
    elif [ "`${CAT} /etc/redhat-release | ${AWK} '{ print $1, $3 }' | ${CUT} -d '.' -f1`" = "CentOS 6" ]; then
      DISTRO=CENTOS6
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

info()  { echo -e $'[\e[1;36m info \e[0m]' "$@" ; }
query() { echo -n $'[\e[1;35mquery \e[0m]' $@ ; }
ok()    { echo $'[\e[1;32m  ok  \e[0m]' $@ ; }
error() { echo $'[\e[1;31merror \e[0m]' $@ ; }
warn()  { echo $'[\e[1;33m warn \e[0m]' $@ ; }

death() { error $@ ; exit 1 ; }

silence() {
  (($@) 2>&1) > /dev/null
  return "${?}"
}

help() { echo "$HELPTEXT" ; exit 0 ; }

main $@

