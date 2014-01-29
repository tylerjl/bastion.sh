#!/usr/bin/env bash

BASTION_TASK_TYPE=$BASTION_TYPE_PASSIVE
BASTION_TASK_CMD="grep -i '^%' /etc/sudoers | awk '{ print \$1; }' | sed 's/^.//' | sort | uniq"

task_precheck() {

  # Is /etc/sudoers readable?
  if [ ! -r /etc/sudoers ] ; then
    echo "cannot read /etc/sudoers"
    return ${BASTION_RAISE_SKIP}
  fi

  return 0
}
