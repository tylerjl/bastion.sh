#!/usr/bin/env bash

BASTION_TASK_TYPE=$BASTION_TYPE_PASSIVE
BASTION_TASK_CMD="crontab -l"

task_precheck() {

  WARN=0

  if ! (ps ax | grep -i 'cron') >/dev/null ; then
    echo "cron may not be running"
    WARN=1
  fi

  if [ "${UID}" = "0" ] || echo "Run as root to see all crontabs?" && confirm ; then
    BASTION_TASK_CMD="for user in \$(awk -F\: '{ print \$1; }' /etc/passwd) ; do ((crontab -l -u \${user} 2>&1) >/dev/null) && (echo \"\${user}:\" ; crontab -u \${user} -l 2>/dev/null ; echo) ; done"
  fi

  [ "${WARN}" = "1" ] && return ${BASTION_RAISE_WARN}

  return 0
}
