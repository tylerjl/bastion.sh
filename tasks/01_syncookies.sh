#!/usr/bin/env bash

FLAG="/proc/sys/net/ipv4/tcp_syncookies"
CMD="/bin/echo 1 > $FLAG"

task_type() { return ${TYPE_MUTABLE} ; }

task_precheck() {
  if [ ! -f $FLAG ] ; then
    echo "$FLAG does not exist"
    return ${RAISE_SKIP}
  elif silence ${GREP} 1 ${FLAG} ; then
    echo "${FLAG} is already set"
    return ${RAISE_SKIP}
  fi
  return 0
}

task_explain() {
  echo "${CMD}"
}

task_run() {
  eval $CMD
}

