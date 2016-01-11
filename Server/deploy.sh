#!/bin/sh

SERVER=165.225.175.252

export COPYFILE_DISABLE=true # exclude Mac OSX resource forks (._*)

tar -cvf server.tar --exclude='.DS_Store' www

scp server.tar root@$SERVER:/root/Server

ssh root@$SERVER "cd /root/Server; tar -xvf server.tar"


echo "Login to server and tail /root/Server/www/server.log"

