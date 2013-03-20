#!/usr/bin/env bash

if [ "${UID}" = "0" ] ; then
  CRONTAB_CMD="for user in \$(awk -F\: '{ print \$1; }' /etc/passwd) ; do ((crontab -l -u \${user} 2>&1) >/dev/null) && (echo \"\${user}:\" ; crontab -u \${user} -l 2>/dev/null ; echo) ; done"
else
  CRONTAB_CMD="crontab -l"
fi

task_type() { return ${TYPE_AUDIT} ; }

task_precheck() {

  WARN=0

  # Is RC local readable?
  if ! (ps ax | grep -i 'cron') >/dev/null ; then
    echo "cron may not be running"
    WARN=1
  elif [ ! "${UID}" = "0" ] ; then
    echo "you are not root, only showing your crontab"
    WARN=1
  fi

  [ "${WARN}" = "1" ] && return 2

  return 0
}

task_explain() {
  echo "Going to show you active crontabs:\n\t\t\t${CRONTAB_CMD}"
}

task_run() {
  CRONTABS="$(eval ${CRONTAB_CMD})"
  if [ ! -z "${CRONTABS}" ] ; then
    echo "${CRONTABS}"
    echo -n "[hit enter to continue]"
    read
  else
    info "no crontabs found"
  fi
}

