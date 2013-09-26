#!/usr/bin/python
# Small python thing to include in your offlineimaprc like this:
# remotepasseval = getmeinpass("<encrypted pass filename")

import os, commands as cmd, subprocess as sub

def getmeinpass(welches):
   file = os.environ['HOME'] + '/.meinkeyring/' + welches + '.gpg'
   if not os.path.isfile(file):
      return False
   p = sub.Popen([os.environ['HOME'] + '/bin/getmeinpass', welches],
         stdout=sub.PIPE, stderr=sub.STDOUT)
   p = p.communicate()[0]
   return p.rstrip()
