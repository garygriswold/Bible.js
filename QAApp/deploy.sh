#!/bin/sh

SERVER=165.225.175.252

export COPYFILE_DISABLE=true # exclude Mac OSX resource forks (._*)

tar -cvf qapp.tar --exclude='.DS_Store' --exclude 'views/' index.html qapp

cp qapp.tar ../StaticRoot

scp qapp.tar root@$SERVER:/root/StaticRoot

cd ../StaticRoot
tar -xvf qapp.tar

ssh root@$SERVER "cd /root/StaticRoot; tar -xvf qapp.tar"


