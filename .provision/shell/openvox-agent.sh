#!/bin/bash

eval $(cat /etc/os-release |grep '=')

raise_error () {
  echo -e "\e[31mfailed\e[0m"
  exit 1
}

usage () {
  echo "$0 usage: -v <7|8>"
  exit 0
}

[ $# -eq 0 ] && usage

while getopts ":h:v:" arg; do
  case $arg in
    v)
      OPENVOX_VERSION=$OPTARG
      ;;
    h | *)
      usage
      ;;
  esac
done

case $ID in
  debian | ubuntu)
    apt-get install -y wget apt-transport-https gpg 2>&1 >/dev/null || raise_error

    if ! [ -f /usr/share/keyrings/openvox-keyring.gpg ]; then
      echo -n "Importing OpenVox GPG key..."
      wget -q https://apt.voxpupuli.org/GPG-KEY-openvox.pub -O- |gpg --dearmor > /usr/share/keyrings/openvox-keyring.gpg || raise_error
      echo "ok"
    fi

    if ! [ -f "/etc/apt/sources.list.d/openvox${OPENVOX_VERSION}-release.list" ]; then
      echo -n "Adding OpenVox repository..."
      $(echo "deb [signed-by=/usr/share/keyrings/openvox-keyring.gpg] https://apt.voxpupuli.org ${ID}${VERSION_ID} openvox${OPENVOX_VERSION}" |tee "/etc/apt/sources.list.d/openvox${OPENVOX_VERSION}-release.list" 2>&1 >/dev/null) || raise_error
      apt-get update 2>&1 >/dev/null || raise_error
      echo "ok"
    fi

    if ! $(dpkg-query --show openvox-agent >/dev/null 2>&1); then
      echo -n "Installing OpenVox agent..."
      apt-get install -y openvox-agent >/dev/null 2>&1 || raise_error
      echo "ok"
    fi

    if $(systemctl status puppet |grep 'puppet.service; enabled;' >/dev/null 2>&1); then
      echo -n "Disable OpenVox agent..."
      systemctl disable --now puppet.service >/dev/null 2>&1 || raise_error
      echo "ok"
    fi

    if ! [ -L /etc/puppetlabs/code/environments/production ]; then
      echo -n "Removing production environment..."
      rm -rf /etc/puppetlabs/code/environments/production >/dev/null 2>&1 || raise_error
      ln -s /root/puppetcode /etc/puppetlabs/code/environments/production >/dev/null 2>&1 || raise_error
      echo "ok"
    fi
    ;;
esac

exit 0
