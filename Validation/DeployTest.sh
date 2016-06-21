#!/bin/sh -v

if [ -z "$1" ]; then
        echo "Usage: DeployTest.sh VERSION";
        exit 1;
fi

SOURCE=$HOME/ShortSands/DBL/3prepared/$1.db

cp $SOURCE "$HOME/Library/Application Support/BibleAppNW/databases/file__0/20"
#cp $SOURCE $HOME/ShortSands/BibleApp/YourBible/www


## To actually deploy a test copy of a Bible to BibleAppNW, we need to do the following steps.
## These steps assume that the Bible version has already be added to Versions.
## 1. Check database/Databases.db for an entry, if exists remember rowId.
## 2. If it does not exist, insert at next available rowId
## 3. The database itself needs to be copied to that rowid
## 4. SettingsStorageInitSettings needs to be modified 
##    a. Add the new version under setVersion
##    b. Can also add entry in defaultVersion of 'en' to make it the default



