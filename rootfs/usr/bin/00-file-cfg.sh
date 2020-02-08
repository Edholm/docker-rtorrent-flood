#!/usr/bin/env bash

# rTorrent + FloodUI
rm -rf /config/rtorrent/session/rtorrent.lock

mkdir -p /volume1/Warez/download/

mkdir -p /config/rtorrent/session
mkdir -p /config/rtorrent/log
mkdir -p /config/rtorrent/watch/tv
mkdir -p /config/rtorrent/watch/movies
mkdir -p /config/flood

if [ ! -f /config/rtorrent/rtorrent.rc ]; then
    cp -r /defaults/config/rtorrent/.rtorrent.rc /config/rtorrent/rtorrent.rc
fi

if [ ! -d /config/flood/db ]; then
    cp -r /defaults/config/flood/db /config/flood/db
fi

chmod 775 -R /config
#chmod 775 -R /volume1/Warez/download

#chown rtorrent: -R /volume1/Warez/download
chown rtorrent: -R /config/rtorrent
chown rtorrent: -R /config/flood