#!/bin/sh 

if [ -z "$1" ]; then
	echo "Usage: Upload.sh VERSION";
	exit 1;
fi

VERSION=$1;

SOURCE=$HOME/ShortSands/DBL/5ready/
HOST=root@cloud.shortsands.com
TARGET=/root/StaticRoot/book/

echo "Upload $VERSION";

cd ${SOURCE}
rm ${VERSION}.db.zip

zip ${VERSION}.db.zip ${VERSION}.db

scp ${SOURCE}${VERSION}.db.zip ${HOST}:${TARGET}

ssh ${HOST} unzip -d ${TARGET} ${TARGET}${VERSION}.db.zip
