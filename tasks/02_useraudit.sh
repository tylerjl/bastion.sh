#!/usr/bin/env sh

CMD_USERLIST="cat /etc/shadow | grep -E -v '^[^:]+:(!!|[*])'"
CMD_KEYLIST="find / -name authorized_keys 2>/dev/null"
CMD_ROOTS="cat /etc/passwd | awk -F\: '{ if (\$3 == \"0\") { print \$1; } }' | grep -v root"

task_type() { return ${TYPE_AUDIT} ; }

task_precheck() {

  RETVAL=0

  # Are required files readable?
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
  echo "\t\tLook for users with UID 0:\n\t\t\t${CMD_ROOTS}"
}

task_run() {
  if [ -r /etc/shadow ] ; then
    echo
    eval ${CMD_USERLIST} 2>/dev/null
    echo
    echo "These users have passwords set and can log in."
    echo "If these users are okay, no further action is required."
    echo "Otherwise, administer your users with usermod."
    echo -n "[hit enter to continue]"
    read
  else
    warn "Cannot read /etc/shadow, skipping check."
  fi

  SSH_AUTHKEYS="$(eval ${CMD_KEYLIST} | grep -v '^$')"
  if [ ! -z "${SSH_AUTHKEYS}" ] ; then
    echo
    echo "${SSH_AUTHKEYS}"
    echo
    echo "These users have trusted public keys. Audit their"
    echo "authorized_keys if they are not trusted accounts."
    [ ${UID} == "0" ] || warn "Note: you're not root and may have missed some."
    echo -n "[hit enter to continue]"
    read
  else
    ok "No authorized_keys files found on the system. Are you root?"
  fi

  if [ -r /etc/passwd ] ; then
    ROOT_ACCTS="$(eval ${CMD_ROOTS})"
    if [ ! -z ${ROOT_ACCTS} ] ; then
      echo
      echo ${ROOT_ACCTS}
      echo
      warn "WARNING!!!!!"
      echo "These users have UID 0. Only root should have UID 0."
      echo "You should investigate this user account IMMEDIATELY."
      echo -n "[hit enter to continue]"
      read
    fi
  else
    info "Cannot read /etc/passwd, skipping check."
  fi
}

