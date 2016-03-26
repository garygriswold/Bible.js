#!/bin/sh

cd /root/Server/www
/usr/bin/node /root/Server/www/Router.js > /root/Server/www/server.log &
