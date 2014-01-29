#!/usr/bin/env bash

BASTION_TASK_TYPE=$BASTION_TYPE_PASSIVE
BASTION_TASK_CMD="grep -E '^[a-z]' /etc/sudoers | sort | uniq"

task_precheck() {

  # Is /etc/sudoers readable?
  if [ ! -r /etc/sudoers ] ; then
    echo "cannot read /etc/sudoers"
    return ${BASTION_RAISE_SKIP}
  fi

  return 0
}
