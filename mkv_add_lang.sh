#/bin/bash

# ~/bin/mkv_add_lang | tee /tmp/sicherheitsnetz | sh

declare -A langcode=(
	[ger]=DE
	[deu]=DE
	[eng]=EN
	[jpn]=JP
	[heb]=HB
	[chi]=CH
	[fre]=FR
	[por]=PT
	[dut]=NL
	[rus]=RU
	[tai]=TH
	[spa]=ES
	[swe]=SE
)

IFS='
' ; for m in $(ls *.mkv | egrep -v '[A-Z][A-Z]\)') ; do
	declare -A langs

	for l in $(ffmpeg -i "$m" 2>&1 | sed -n '/^\s*Stream #[^(]\+(\([^)]\+\).* Audio.*$/{s//\1/;p}') ; do
		if [ -z "${langcode[$l]}" ] ; then
			echo "Unknown language: $l"
			exit 1
		fi
		langs+=([${langcode[$l]}]=1)
	done

	for l in ${!langs[@]} ; do
		ll+=", $l"
	done

	newm=$(echo $m | sed 's/).mkv/'$ll').mkv/')
	if [ "$m" != "$newm" ] ; then
		echo mv -n \'$m\' \'$newm\'
	fi

	unset newm l langs ll
done

