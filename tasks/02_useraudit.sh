#!/usr/bin/env bash

CMD_USERLIST="cat /etc/shadow | grep -E -v '^[^:]+:(!!|[*])'"
CMD_KEYLIST="find / -name authorized_keys 2>/dev/null"

task_precheck() {

  # Is /etc/shadow readable?
  if [ ! -r /etc/shadow ] ; then
    echo "cannot read /etc/shadow"
    return 2
  fi

  return 0
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

