#!/bin/bash - 

set -e

skip="$(sed 's/[^0-9].*//' /sys/devices/system/cpu/cpu*/topology/thread_siblings_list |\
   sort | uniq)"

cpus="$(echo /sys/devices/system/cpu/cpu[0-9]* |\
   sed 's/[^ ]*cpu\([0-9]\+\)/\1/g' | tr ' ' '\n')"


echo "$cpus" | grep -v -x -f <(echo "$skip") |\
   xargs -n1 printf "echo 0 > /sys/devices/system/cpu/cpu%d/online\n" |\
   /bin/sh
