
#######################################################################
# fancy background stuff

(
      dir="$HOME/.wallpaper"
      ctime=0
      y=0

      while [ -d "$dir" ]; do
      # update file list if directory has changed
      if [ $ctime != $(stat -c '%Z' $dir) ] ; then
         ctime=$(stat -c '%Z' $dir)
         range=`find "$dir" -type f | wc -l`
         IFS='
'
         wallpapers=($(find "$dir" -type f))
         unset IFS
      fi

      let "number = $RANDOM % ($range-1)"

      # avoid displaying the same picture again
      if [ $number = $y ] ; then
         let "number = ($number + 1) % ($range-1)"
      fi

      y=$number

      # make a copy of the wallpaper for the lockscreen
      # i3lock -i /tmp/.wallpaper.png -t
      convert "${wallpapers[$number]}" \
	-resize "$(xrandr | awk '/*/{print $1; exit}')^" \
	-gravity center -crop "$(xrandr | awk '/*/{print $1; exit}')+0+0" \
	+repage /tmp/.wallpaper.png &

      # reset chosen wallpaper in decreasing intervalls to avoid
      # awesome wallpaper interference at startup
      for t in 30s 90s 28m ; do
         if [ "$(hostname)" == "adminwks06" ] ; then
            convert "${wallpapers[$number]}" "${wallpapers[$number]}" \
	      +append -quality 85 /tmp/.combined.jpg
            feh --bg-fill /tmp/.combined.jpg
         else
            feh --bg-fill "${wallpapers[$number]}"
         fi
         sleep $t
      done
   done
) &

