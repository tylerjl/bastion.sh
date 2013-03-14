#!/usr/bin/env sh

CMD_USERLIST="cat /etc/shadow | grep -E -v '^[^:]+:(!!|[*])'"
CMD_KEYLIST="find / -name authorized_keys 2>/dev/null"

task_type() { return ${TYPE_AUDIT} ; }

task_precheck() {

  RETVAL=0

  # Is /etc/shadow readable?
  CHECKFILES="shadow passwd"
  for f in ${CHECKFILES} ; do
    if [ ! -r /etc/${f} ] ; then
      echo "cannot read /etc/${f}"
      RETVAL=2
    fi
  done

  return ${RETVAL}
}

task_explain() {
  echo "Going to show you a list of users for validation:\n\t\t\t${CMD_USERLIST}"
  echo "\t\tFind a list of users with public keys:\n\t\t\t${CMD_KEYLIST}"
}

task_run() {
  echo
  eval ${CMD_USERLIST}
  echo
  echo "These users have passwords set and can log in."
  echo "If these users are okay, no further action is required."
  echo "Otherwise, administer your users with usermod."
  echo "[hit enter to continue]"
  read
  echo
  eval ${CMD_KEYLIST}
  echo
  echo "These users have trusted public keys. Audit their authorized_keys"
  echo "if they are not trusted accounts."
  echo "[hit enter to continue]"
  read
}

