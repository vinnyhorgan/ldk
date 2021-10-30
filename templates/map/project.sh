#!/bin/bash

if [ "$1" = "init" ]
then
	wget https://github.com/mapeditor/tiled/releases/download/v1.7.2/Tiled-1.7.2-x86_64.AppImage
	mv Tiled-1.7.2-x86_64.AppImage tiled
	chmod +x tiled
elif [ "$1" = "edit" ]
then
	./tiled
else
	echo "Usage: ./project.sh [init|edit]"
fi
