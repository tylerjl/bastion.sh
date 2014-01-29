#!/usr/bin/env bash

RC_LOCAL="/etc/rc.local"

BASTION_TASK_TYPE=$BASTION_TYPE_PASSIVE
BASTION_TASK_CMD="grep -v -i -E '^(#|$)' ${RC_LOCAL}"

task_precheck() {

  # Is RC local readable?
  if [ ! -r /etc/rc.local ] ; then
    echo "cannot read /etc/rc.local"
    return ${BASTION_RAISE_SKIP}
  fi

  return 0
}
