#!/bin/bash

if [ "$1" = "run" ]
then
	../../tools/love .
elif [ "$1" = "edit" ]
then
	../../tools/lite . &
elif [ "$1" = "package" ]
then
	# Create .love file
	zip -9 -r game.love . -x \*.sh

	# Create windows release
	cp -r ../../export/windows .
	cat windows/love.exe game.love > game.exe
	mv windows/template .
	rm -rf windows
	mv game.exe template
	mv template windows
	zip -9 -r windows.zip windows
	rm -rf windows

	# Create macos release
	cp -r ../../export/macos .
	cp -r macos/template game.app
	rm -rf macos
	cp game.love game.app/Contents/Resources
	zip -9 -r -y macos.zip game.app
	rm -rf game.app

	# Create linux release
	cp -r ../../export/linux .
	cp game.love linux/squashfs-root
	../../tools/appimagetool linux/squashfs-root
	rm -rf linux
	mv LÖVE-x86_64.AppImage linux.AppImage

	# Move releases to folder
	mkdir -p releases

	mv game.love releases
	mv windows.zip releases
	mv macos.zip releases
	mv linux.AppImage releases
else
	echo "Usage: ./project.sh [run|edit|package]"
fi