#!/bin/bash

if [ "$1" = "run" ]
then
	../../tools/love .
elif [ "$1" = "edit" ]
then
	../../tools/lite . &
elif [ "$1" = "server" ]
then
	../../tools/love ./server
elif [ "$1" = "package" ]
then
	directory=${PWD##*/}

	chmod +x server/project.sh
	mv server ..

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
	mkdir -p releases/client

	mv game.love releases/client
	mv windows.zip releases/client
	mv macos.zip releases/client
	mv linux.AppImage releases/client

	# Create server release
	cd ../server
	./project.sh package
	mv releases server
	mv server ../"$directory"/releases
	cd ../$directory
	mv ../server .
else
	echo "Usage: ./project.sh [run|edit|package|server]"
fi
