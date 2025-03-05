#!/bin/bash

eval $(cat /etc/os-release |grep '=')

usage () {
  echo "$0 usage: -u <user> -h <host> -s <source> -d <destination>"
  exit 0
}

[ $# -eq 0 ] && usage

while getopts ":h:s:d:u:" arg; do
  case $arg in
    s)
      SRC=$OPTARG
      ;;
    d)
      DST=$OPTARG
      ;;
    u)
      USER=$OPTARG
      ;;
    h)
      HOST=$OPTARG
      ;;
    --help | *)
      usage
      ;;
  esac
done

case $ID in
  debian | ubuntu)
    if ! $(dpkg-query --show sshfs >/dev/null 2>&1); then
      apt-get install -y sshfs >/dev/null 2>&1 || exit 1
    fi

    if ! $(grep "^sshfs#${USER}@${HOST}:${SRC}\s*${DST}\s*fuse" /etc/fstab >/dev/null 2>&1); then
      if $(awk '{ print $2 }' /etc/fstab |grep $DST >/dev/null 2>&1); then
        echo "${DST} is already mounted"
        exit 1
      fi
      echo "sshfs#${USER}@${HOST}:${SRC} ${DST} fuse IdentityFile=/root/.ssh/identity,StrictHostKeyChecking=no,defaults,_netdev,allow_other 0 0" >> /etc/fstab && systemctl daemon-reload
    fi

    if ! [ -d $DST ]; then
      mkdir -p $DST || exit 1
    fi

    if ! $(mount |grep "on ${DST} type fuse" >/dev/null 2>&1); then
      mount $DST || exit 1
    fi
    ;;
esac

exit 0
