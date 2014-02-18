#!/usr/bin/env sh

BASTION_TASK_TYPE=$BASTION_TYPE_PASSIVE
BASTION_TASK_CMD='find / -name authorized_keys 2>/dev/null | grep -v "^$"'

task_precheck() {

  RETVAL=0

  if [ "${UID}" != "0" ] ; then
    echo "Run with root privileges to find all authorized_keys files?"
    if confirm ; then
      BASTION_TASK_CMD="sudo su -c '${BASTION_TASK_CMD}'"
    else
      warn "Will only find authorized_key files you have permissions to read"
    fi
  fi

  return ${RETVAL}
}
