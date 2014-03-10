geskripte
=========

Various scripts, code-snippets, commands and install logs. Written by me and beerware unless otherwise indicated in the readme.

##### 2xvid
Short script used to convert DVB-T recordings in interlaced MPEG2 into something less painful.

##### chrony
Shell wrapper for non-painful interaction with the chrony NTP daemon

##### disable\_hyperthreading.sh
Disables hyperthreading by offlining CPU cores

##### fork\_hostname.sh
Simple wrapper to start programms in a namespace with a different hostname. Needs sudo rights or a setuid bit on unshare(1).

##### getmeinpass
Small keyring-like funktionality that uses gpg with gpg-agent to store passwords encrypted.

##### getmeinpass\_offlineimap.py
Function to include getmeinpass into offlineimap

##### gpg-agent.sh
Starts gpg-agent if necessary and sets environment to have a painless gpg-/ssh-agent in the background

##### lowlat.pl
compare ping round-trip times of a bunch of hosts to find the nearest machine to log in to

##### magnet.sh
Creates a torrent from a magnet link. Put this in your browser and configure your torrent client to pick up the torrents from the download directory.

##### make.soup
Makefile to mirror the images you posted on soup.io

##### mkv\_add\_lang
Reads audios track information from MKV files and outputs rename commands to reflect the language of them in the filename. Only works with a naming scheme ending with ").mkv".

##### myip\_opendns.sh
Small wrapper around dig to query opendns.com. Returns ones public IP address.

##### newznab\_stat\_releases.sh
Query a newznab mysql database and grab a few stats.

##### randsort.pl
Use in pipe instead of sort(1) to un-sort input. Sometimes you just want to have a random episode. :-)

##### ssh-copy-id
Small shell script version of the popular tool. Author: unknown

##### ssh\_script
Small wrapper that documents you ssh session

##### ssl-management.make
SSL-Management in a makefile! See the beginning of the file for a description. Configure like this:

```Shell
sed -i \
	-e "s/<<MyOrg>>/$(ssl_MyOrg)/g" \
	-e "s/<<MyCity>>/$(ssl_MyCity)/g" \
	-e "s/<<MyState>>/$(ssl_MyState)/g" \
	-e "s/<<MyCC>>/$(ssl_MyCC)/g" \
	ssl-management.make
```

##### upload.php
Supersimple PHP upload form script. Better don't use this.

##### vils
Edit filenames. Author: Oliver Fromme

##### wallpaper.sh
A snippet from my .xprofile that changes the desktop wallpaper every half hour.

##### wireshark\_colorfilters & wireshark\_macros
Some wireshark coloring rules and display filters that I like to use. In config file format - you'll have to do some level 8 parsing if you want to enter them in the GUI preferences.
