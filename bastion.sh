#!/usr/bin/env sh

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

Usage: $0 [-yvdpmfh]
  -y  answer yes to all (run automatically)
  -v  verbose
  -d  enable debugging output
  -p  perform only passive checks (do not alter the host system)
  -m  perform only checks that will actively modify the system
  -f  force checks even if distro validation fails
  -h  display this help text"

CAT="$(which cat)"
AWK="$(which awk)"
CUT="$(which cut)"
GREP="$(which grep)"

TYPE_AUDIT=200
TYPE_MUTABLE=201

RAISE_SKIP=1
RAISE_WARN=2
RAISE_INF0=3

#####################
# Script entry point.

main() {

  # TODO: Uncomment in prod.
  # [ "${UID}" == "0" ] || death "This program must be run as root.  Exiting."

  while getopts ":yvdpmfh" opt ; do
    case $opt in
      y) AUTO=1 ;;
      v) VERBOSE=1 ;;
      d) DEBUG=1 ;;
      p) PASSIVE=1 ;;
      m) MUTABLE=1 ;;
      f) FORCE=1 ;;
      h) help ;;
    esac
  done

  [ ${MUTABLE} ] && [ ${PASSIVE} ] && death "Choose only one: -p or -m."

  [ ${FORCE} ] || distro_check || death "Unsupported Linux distribution."

  [ $DEBUG ] || [ $VERBOSE ] && info "Got distro of: $DISTRO"

  for script in ./tasks/* ; do

    if [ ! -x $script ] ; then
        info "${script} cannot be reading, skipping it"
        continue
    fi

    TASK="$(basename $script | \
      sed 's/^[^a-zA-Z]*\([a-zA-Z]\{1,\}\)[.][a-z]\{1,\}$/\1/')"

    echo ; banner ${TASK}

    source $script

    # Skip non-audit tasks
    if [ "${PASSIVE}" = 1 ] || [ "${MUTABLE}" = 1 ] ; then
      task_type ; TASK_TYPE=${?}
      if [ ${PASSIVE} ] && [ "${TASK_TYPE}" != "${TYPE_AUDIT}" ] ; then
        info "${TASK} is not passive, skipping."
        continue
      elif [ ${MUTABLE} ] && [ "${TASK_TYPE}" != "${TYPE_MUTABLE}" ] ; then
        info "${TASK} is not mutable, skipping."
        continue
      fi
    fi

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

  quit
}

quit() {
  echo ; ok "Completed $(basename $0)"
  exit 0
}

prevalidate() {
  CHECK_INFO="$($2)"
  RET=$?

  if [ "${RET}" = 0 ] ; then
    return 0
  elif [ "${RET}" = ${RAISE_SKIP} ] ; then
    info "${CHECK_INFO}, skipping ${1}"
    return 1
  elif [ "${RET}" = ${RAISE_WARN} ] ; then
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
  query "Proceed? (y/n/q): "
  read PROCEEDASK

  until [ "${PROCEEDASK}" = "y" ] || \
        [ "${PROCEEDASK}" = "n" ] || \
        [ "${PROCEEDASK}" = "q" ]; do
    query "Please enter 'y' or 'n' (or 'q' to quit): "
    read PROCEEDASK
  done

  if [ ${PROCEEDASK} = "n" ] ; then
    return 1
  elif [ ${PROCEEDASK} = "q" ] ; then
    quit
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

banner()  { echo "==> $@" ; }
info()    { echo -e $'[\e[1;36m info \e[0m]' "$@" ; }
query()   { echo -e $'[\e[1;35mquery \e[0m]' $@ ; }
ok()      { echo -e $'[\e[1;32m  ok  \e[0m]' $@ ; }
error()   { echo -e $'[\e[1;31merror \e[0m]' $@ ; }
warn()    { echo -e $'[\e[1;33m warn \e[0m]' $@ ; }

death() { error $@ ; exit 1 ; }

silence() {
  (($@) 2>&1) > /dev/null
  return "${?}"
}

help() { echo "$HELPTEXT" ; exit 0 ; }

main $@

