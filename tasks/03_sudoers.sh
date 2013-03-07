#!/usr/bin/env bash

SUDOER_GROUPS="grep -i '^%' /etc/sudoers | awk '{ print \$1; }' | sed 's/^.//' | sort | uniq"
SUDOER_USERS="grep -E '^[a-z]' /etc/sudoers | sort | uniq"

task_precheck() {

  # Is /etc/sudoers readable?
  if [ ! -r /etc/sudoers ] ; then
    echo "cannot read /etc/sudoers"
    return 2
  fi

  return 0
}

task_explain() {
  echo "Going to show you users who can sudo:\n\t\t\t${SUDOER_GROUPS}"
  echo "\t\t\t${SUDOER_USERS}"
}

task_run() {

  S_GROUPS=$(eval ${SUDOER_GROUPS})

  if [ "${S_GROUPS}" != "" ] ; then
    echo
    echo "The following groups have sudo permissions:"
    echo
    for group in $S_GROUPS ; do
      echo -e "\t$(grep $group /etc/group)"
    done
    echo
    echo "[hit enter to continue]"
    read
  fi

  S_USERS=$(eval ${SUDOER_USERS})

  if [ "${S_USERS}" != "" ] ; then
    echo
    echo "These users have the following direct entries in the sudoers file:"
    echo
    echo -e "\t${S_USERS}"
    echo
    echo "[hit enter to continue]"
    read
  fi
}

