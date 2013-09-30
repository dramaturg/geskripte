#!/bin/bash

set -e

if [ "$(whoami)" == "root" ] ; then
	hostname $1
	exec su - "$SUDO_USER" -c "$0 $*"
fi

if [ "$(hostname)" != "$1" ] ;then
	exec sudo unshare --uts $0 $*
fi

shift
exec $*

