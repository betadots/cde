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
    ;;
  rocky | almalinux | redhat | fedora | centos)
    if ! $(rpm -iq fuse-sshfs >/dev/null 2>&1); then
      dnf install -y fuse-sshfs || exit 1
    fi
    ;;
esac

if ! $(grep ".*\s*${DST}" /etc/fstab >/dev/null 2>&1); then
  echo "${USER}@${HOST}:${SRC} ${DST} fuse.sshfs IdentityFile=/root/.ssh/identity,StrictHostKeyChecking=no,_netdev,allow_other 0 0" >> /etc/fstab && systemctl daemon-reload
else
  echo "/etc/fstab: ${DST} is already occupied by a mount"
  exit 1
fi

if ! [ -d $DST ]; then
  mkdir -p $DST || exit 1
fi

if ! $(mount |grep "on ${DST}" >/dev/null 2>&1); then
  nohup mount $DST >/dev/null 2>&1
else
  echo "mount: ${DST} is already occupied by a mount"
  exit 1
fi

exit 0
