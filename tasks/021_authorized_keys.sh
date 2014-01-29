#!/usr/bin/env sh

BASTION_TASK_TYPE=$BASTION_TYPE_PASSIVE
BASTION_TASK_CMD='find / -name authorized_keys 2>/dev/null | grep -v "^$"'

task_precheck() {

  RETVAL=0

  if [ "${UID}" == "0" ] ; then
    echo "Running without root privs, not all authorized_keys will be found."
    RETVAL=$BASTION_RAISE_WARN
  fi

  return ${RETVAL}
}
