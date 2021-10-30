#!/bin/bash

mkdir -p projects

if [ "$1" = "new" ]
then
	cp -r templates/"$2" projects/"$3"
	chmod +x projects/"$3"/project.sh
	echo "Created new project $3 using $2 template."
elif [ "$1" = "init" ]
then
	tar -xvf data.tar.xz
	rm data.tar.xz
	mv data/tools .
	mv data/export .
	rm -r data
	chmod +x tools/appimagetool
	chmod +x tools/love
else
	echo "Usage: ./ldk.sh [init|new] [template] [name]"
fi
