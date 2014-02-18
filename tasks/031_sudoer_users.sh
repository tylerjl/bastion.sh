#!/usr/bin/env bash

BASTION_TASK_TYPE=$BASTION_TYPE_PASSIVE
BASTION_TASK_CMD="grep -E '^[a-z]' /etc/sudoers | sort | uniq"

task_precheck() {

  # Is /etc/sudoers readable?
  if [ ! -r /etc/sudoers ] ; then
    warn "cannot read /etc/sudoers. Try to run with sudo?"
    if confirm ; then
      BASTION_TASK_CMD="sudo su -c \"${BASTION_TASK_CMD}\""
    else
      return ${BASTION_RAISE_SKIP}
    fi
  fi

  return 0
}
