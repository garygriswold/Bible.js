#!/bin/sh

SERVER=cloud.shortsands.com

export COPYFILE_DISABLE=true # exclude Mac OSX resource forks (._*)

tar -cvf server.tar --exclude='.DS_Store' www

scp -P7022 server.tar root@$SERVER:/root/Server

ssh root@$SERVER -p7022 "cd /root/Server; tar -xvf server.tar"


echo "Login to server and tail /root/Server/www/server.log"

