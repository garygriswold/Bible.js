#!/bin/sh

export COPYFILE_DISABLE=true # exclude Mac OSX resource forks (._*)

tar -cvf server.tar --exclude='.DS_Store' www

scp server.tar root@165.225.166.55:/root/Server

ssh root@165.225.166.55 "cd /root/Server; tar -xvf server.tar"

ssh root@165.225.166.55 "cd /root/Server/www; ./ServerProd.sh"

echo "Login to server and tail /root/Server/www/server.log"

