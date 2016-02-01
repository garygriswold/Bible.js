#!/bin/sh 

if [ -z "$1" ]; then
	echo "Usage: Upload.sh VERSION";
	exit 1;
fi

VERSION=$1;

SOURCE=$HOME/DBL/5ready/
HOST=root@qa.your-bible.org
TARGET=/root/StaticRoot/book/

echo "Upload $VERSION";

cd ${SOURCE}
rm ${VERSION}.db1.zip

zip ${VERSION}.db1.zip ${VERSION}.db1

scp ${SOURCE}${VERSION}.db1.zip ${HOST}:${TARGET}

ssh ${HOST} unzip -d ${TARGET} ${TARGET}${VERSION}.db1.zip