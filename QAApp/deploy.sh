#!/bin/sh

export COPYFILE_DISABLE=true # exclude Mac OSX resource forks (._*)

tar -cvf qapp.tar --exclude='.DS_Store' --exclude 'views/' index.html qapp

cp qapp.tar ../StaticRoot

scp qapp.tar root@qa.shortsands.com:/root/StaticRoot

cd ../StaticRoot
tar -xvf qapp.tar

ssh root@qa.shortsands.com "cd /root/StaticRoot; tar -xvf qapp.tar"


