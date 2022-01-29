#!/bin/sh
apt-get update  # To get the latest package lists
apt-get install transmission-daemon -y # Install transmission torrent client
apt-get install zip -y # Install transmission torrent client
/usr/bin/transmission-daemon # Start the transmision daemon
