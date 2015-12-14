#!/bin/sh

cd /root/Server/www
/opt/local/bin/node /root/Server/www/Router.js > /root/Server/www/server.log &
