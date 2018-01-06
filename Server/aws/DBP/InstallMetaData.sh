#!/bin/sh -ev

PROJECT=$HOME/ShortSands/BibleApp/Plugins/AudioPlayer/src/ios_AudioPlayer/AudioPlayer

sqlite $PROJECT/Versions.db < $PROJECT/CreateTables.sql
sqlite $PROJECT/Versions.db < output/AudioVersionTable.sql
sqlite $PROJECT/Versions.db < output/AudioTable.sql
sqlite $PROJECT/Versions.db < output/AudioBookTable.sql