#!/usr/bin/env bash

RC_LOCAL="/etc/rc.local"
STARTUP_CMD="grep -v -i -E '^(#|$)' ${RC_LOCAL}"

task_type() { return ${TYPE_AUDIT} ; }

task_precheck() {

  # Is RC local readable?
  if [ ! -r /etc/rc.local ] ; then
    echo "cannot read /etc/rc.local"
    return 2
  fi

  return 0
}

task_explain() {
  echo "Going to show you startup scripts:\n\t\t\t${RC_LOCAL}"
}

task_run() {
  echo
  echo "The following commands run at boot time:"
  echo
  echo -e "\t$(eval ${STARTUP_CMD})"
  echo
  echo -n "[hit enter to continue]"
  read
}

