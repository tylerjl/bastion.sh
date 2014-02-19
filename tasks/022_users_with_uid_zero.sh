#!/usr/bin/env sh

BASTION_TASK_TYPE=$BASTION_TYPE_PASSIVE
BASTION_TASK_CMD="cat /etc/passwd | awk -F\: '{ if (\$3 == \"0\") { print \$1; } }' | grep -v root && echo 'WARNING: These users have UID 0!!' || echo 'No bad users found!'"

task_precheck() {

  RETVAL=0

  # Are required files readable?
  CHECKFILES="passwd"
  for f in ${CHECKFILES} ; do
    if [ ! -r /etc/${f} ] ; then
      echo "cannot read /etc/${f}"
      RETVAL=${BASTION_RAISE_SKIP}
    fi
  done

  return ${RETVAL}
}
