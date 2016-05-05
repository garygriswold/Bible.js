#!/bin/sh -v

if [ -z "$1" ]; then
        echo "Usage: DeployTest.sh VERSION";
        exit 1;
fi

SOURCE=$HOME/ShortSands/DBL/5ready/$1.db1

cp $SOURCE "$HOME/Library/Application Support/BibleAppNW/databases/file__0/1"
cp $SOURCE $HOME/ShortSands/BibleApp/YourBible/www



