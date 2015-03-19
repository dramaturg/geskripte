#!/bin/bash

set -e

if [[ "$(whoami)" == "root" && -n "$SUDO_USER" && -n "$PARENT" ]] ; then
	hostname $1
	unset PARENT
	exec su "$SUDO_USER" -c "$0 $*"
fi

if [ "$(hostname)" != "$1" ] ;then
	export PARENT=$$
	exec sudo -E unshare --uts $0 $*
fi

shift
exec $*

