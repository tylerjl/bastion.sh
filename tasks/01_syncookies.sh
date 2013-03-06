#!/usr/bin/env bash

FLAG="/proc/sys/net/ipv4/tcp_syncookies"
CMD="/bin/echo 1 > $FLAG"

task_precheck() {
  if [ ! -f $FLAG ] ; then
    echo "$FLAG does not exist"
    return 2
  elif silence ${GREP} 1 ${FLAG} ; then
    echo "${FLAG} is already set"
    return 1
  fi
  return 0
}

task_explain() {
  echo "${CMD}"
}

task_run() {
  eval $CMD
}

