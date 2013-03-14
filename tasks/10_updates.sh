#!/usr/bin/env bash

# Find the distro and set the appropriate package manager and update command
if echo "${DISTRO}" | grep -E -i '(centos|rh|fc)' >/dev/null ; then
  # Yum-based
  PKG_MGR="$(which yum)"
  UPDATE_CMD="${PKG_MGR} update -y"
else
  # DPKG based
  PKG_MGR="$(which apt-get)"
  UPDATE_CMD="${PKG_MGR} upgrade -y"
fi

task_type() { return ${TYPE_MUTABLE} ; }

task_precheck() {

  # Ensure the package manager is present
  if ! silence which $PKG_MGR ; then
    echo "${PKG_MGR} does not exist"
    return 3
  fi

  for bin in wc bc ; do
    if ! silence which $bin ; then
      echo "${bin} binary is missing"
      return 4
    fi
  done

  if [ "$(basename ${PKG_MGR})" = "yum" ] ; then
    UPDATE_CHECK="$(${PKG_MGR} list updates -q 2>/dev/null | wc -l | xargs echo -1 + | bc)"
  elif [ "$(basename ${PKG_MGR})" = "apt-get" ] ; then
    if ! silence ${PKG_MGR} update ; then
      echo "Could not update ${PKG_MGR}"
      return 5
    fi
    UPDATE_CHECK="$(${PKG_MGR} -q --assume-no 2>/dev/null | grep installed | awk '{ print $1; }')"
  fi

  if [ ${UPDATE_CHECK} -lt 0 ] ; then
    echo "No updates available"
    return 1
  fi

  return 0
}

task_explain() {
  if [ "$(basename ${PKG_MGR})" = "yum" ] ; then
    UPDATE_CHECK="$(${PKG_MGR} list updates -q 2>/dev/null | wc -l | xargs echo -1 + | bc)"
  elif [ "$(basename ${PKG_MGR})" = "apt-get" ] ; then
    UPDATE_CHECK="$(${PKG_MGR} upgrade -q --assume-no 2>/dev/null | grep installed | awk '{ print $1; }')"
  fi

  echo "Going to install ${UPDATE_CHECK} updates with:\n\t\t\t${UPDATE_CMD}"
}

task_run() {
  eval $UPDATE_CMD
}

