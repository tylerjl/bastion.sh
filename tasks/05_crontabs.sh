#!/usr/bin/env bash

BASTION_TASK_TYPE=$BASTION_TYPE_PASSIVE
BASTION_TASK_CMD="crontab -l"

task_precheck() {

  if ! (ps ax | grep -i 'cron') >/dev/null ; then
    warn "cron may not be running"
  fi

  if [ "${UID}" == "0" ] || echo "Run as root to see all crontabs?" && confirm ; then
    BASTION_TASK_CMD="for user in \$(awk -F\: '{ print \$1; }' /etc/passwd) ; do if ((sudo crontab -l -u \${user} 2>&1) >/dev/null) ; then (echo \"\${user}:\" ; sudo crontab -u \${user} -l 2>/dev/null ; echo) ; else continue ; fi ; done"
  else
    info "Will only see `whoami`'s crontab"
  fi

  return 0
}
