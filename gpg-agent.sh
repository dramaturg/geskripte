#!/bin/sh
# start gpg-agent or set environment accordingly if it is already running

gnupginf="${HOME}/.gpg-agent-info"

if $(pgrep -u "${USER}" gpg-agent >/dev/null 2>&1); then
    eval `cat $gnupginf`
    #eval `cut -d= -f1 $gnupginf | xargs echo export`
else
   sed -i '/^write-env-file /c\
write-env-file '"${HOME}"'/.gpg-agent-info
' ${HOME}/.gnupg/gpg-agent.conf
    eval `gpg-agent -s --enable-ssh-support --daemon`
fi