#!/usr/bin/env sh

BASTION_TASK_TYPE=$BASTION_TYPE_PASSIVE
BASTION_TASK_CMD="echo 'Users with passwords:' ; cat /etc/shadow | grep -E -v '^[^:]+:(!!|[*])'"

task_precheck() {

  RETVAL=0

  # Are required files readable?
  CHECKFILES="shadow"
  for f in ${CHECKFILES} ; do
    if [ ! -r /etc/${f} ] ; then
      info "cannot read /etc/${f}. Attempt with sudo?"
      if confirm ; then
        TRY_SUDO=1
      else
        RETVAL=${BASTION_RAISE_SKIP}
      fi
    fi
  done

  if [ $TRY_SUDO ] ; then
    BASTION_TASK_CMD="sudo su -c \"${BASTION_TASK_CMD}\""
  fi

  return ${RETVAL}
}
