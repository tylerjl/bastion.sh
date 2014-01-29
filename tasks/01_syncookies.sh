#!/usr/bin/env bash

FLAG="/proc/sys/net/ipv4/tcp_syncookies"

BASTION_TASK_TYPE=$BASTION_TYPE_ACTIVE
BASTION_TASK_CMD="/bin/echo 1 > $FLAG"

task_precheck() {
  if [ ! -f $FLAG ] ; then
    error "$FLAG does not exist"
    return ${BASTION_RAISE_SKIP}
  elif [ ! -r $FLAG ] ; then
    warn "$FLAG cannot be read, attempting with sudo..."
    return ${BASTION_RAISE_SKIP}
  elif silence ${GREP} 1 ${FLAG} ; then
    info "${FLAG} is already set"
    return ${BASTION_RAISE_SKIP}
  fi
  return 0
}
