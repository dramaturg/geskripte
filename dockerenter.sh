#!/bin/bash - 

set -o errexit
set -o nounset

PID="$(docker inspect --format {{.State.Pid}} $1)"
shift

nsenter --target $PID --mount --uts --ipc --net --pid $@
