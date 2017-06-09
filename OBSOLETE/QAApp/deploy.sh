#!/bin/sh

SERVER=cloud.shortsands.com

export COPYFILE_DISABLE=true # exclude Mac OSX resource forks (._*)

tar -cvf qapp.tar --exclude='.DS_Store' --exclude 'views/' index.html qapp

cp qapp.tar ../StaticRoot

scp -P7022 qapp.tar root@$SERVER:/root/StaticRoot

cd ../StaticRoot
tar -xvf qapp.tar

ssh root@$SERVER -p7022 "cd /root/StaticRoot; tar -xvf qapp.tar"


