#!/bin/sh
#
# This is not tested in any way - just an early draft to encode my DVB-recordings
#
# June 2008 -  Sebastian Krohn <seb@gaia.sunn.de>
#

infile="$1"
outfile=$(echo $infile | sed s'/\....[.]*$//').avi

if [ ! -f "$infile" ] ; then
	echo "Check in/output arguments!!!"
	exit 1
fi

# detect crappy cropping
# DON'T ASK! -endpos did't work like in the manpage ... :-/

( sleep 5 ; pkill mplayer ) &
crapping=$(mplayer -vo null -ao null -vf cropdetect "$infile" 2>/dev/null | awk -F'[\(\)]*' '/-vf crop=/ {crap=$2} END {print crap}')


# add this to your ~/.mplayer/mencoder.conf - doing it the hacker way :-)

test -f ~/.mplayer/mencoder.conf && \
  grep '^\[xvid\]$' ~/.mplayer/mencoder.conf >/dev/null || \
  cat << EOF >> ~/.mplayer/mencoder.conf || exit 1

[xvid]
ovc=xvid=1
vf=pp=ci/al/ha:128:7/va/dr,hqdn3d,scale=640:-10
xvidencopts=vhq=4:bvhq=1:chroma_opt=1:fixed_quant=8:quant_type=mpeg:lumi_mask=1:threads=4
oac=mp3lame=1
lameopts=vbr=3:q=5
ffourcc=DX50
EOF


# add crappy crapping to -vf options from mencoder.conf

crapping=$crapping,$(awk 'BEGIN {while (!match($0, /^\[xvid\]$/)) {getline}} /^vf=/ {sub("vf=", ""); print $0; exit}' ~/.mplayer/mencoder.conf)


# TODO - 2-pass encoding (1-pass sufficient for now - needs long enough as it is)

# do the actual encoding

mencoder -profile xvid $crapping -o "$outfile" "$infile"

