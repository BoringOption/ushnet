#!/bin/bash

function puts() {
	printf "%s\r\n" "$*"
}

function change_group() {
	GROUPDIR="$NEWSDIR/$(tr '.' '/' <<< "$1")"
	if [ -d $GROUPDIR ]
	then
		cd $GROUPDIR
		GROUP=$1
		GROUP_MIN=$(ls | sort | head -n 1)
		GROUP_MIN=${GROUP_MIN:-0}
		GROUP_MAX=$(ls | sort | tail -n 1)
		GROUP_MAX=${GROUP_MAX:-0}
		return 0
	else
	  return 1
	fi
}

function select_article() {
	if [ -e "$GROUPDIR/$1" ]
	then
	  ARTICLE=$1
		ARTICLEPATH="$GROUPDIR/$ARTICLE"
		return 0
	else
		return 1
	fi
}

NEWSDIR=${NEWSDIR:-./news}

GROUP=""

ARTICLE=0

tr -d "\r" </dev/stdin | while read -r cmd args
do
	case $cmd in 
		GROUP)
			read -r grp rest <<< "$args"
			if change_group $grp
			then
				puts "211 $(($GROUP_MAX - $GROUP_MIN)) $GROUP_MIN $GROUP_MAX $GROUP group selected"
			else
				puts "411 no such news group"
			fi
			;;
		ARTICLE)
			if [ ! -z $GROUP ]
			then
				read -r article rest <<< "$args"
			  if grep "<\S+>" <<< "$article"
				then
					retrieve_article_id $article
				else
					if [ ! -z $article ]
					then
						if select_article $article
						then
						  puts "211"
							cat "$ARTICLEPATH"
						else
							puts "423"
						fi
					else

					fi
			  fi
			else
				puts "412 no newsgroup has been selected"
			fi
			;;
		QUIT)
			puts "205 closing connection - goodbye!"
			exit 0
			;;
	esac
done
