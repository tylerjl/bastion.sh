#!/usr/bin/env bash

type() { echo AUDIT ; }

if [ "${UID}" = "0" ] ; then
  CRONTAB_CMD="for user in \$(awk -F\: '{ print \$1; }' /etc/passwd) ; do echo \$user: ; crontab -u \$user -l 2>/dev/null ; done"
else
  CRONTAB_CMD="crontab -l"
fi

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
  echo
  eval ${CRONTAB_CMD}
  echo
  echo "[hit enter to continue]"
  read
}

