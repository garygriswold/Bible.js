#!/bin/sh

sqlite3 Versions.db < Versions.sql

cp Versions.db "$HOME/Library/Application Support/BibleAppNW/databases/file__0/9"

cp Versions.db ../YourBible/www/Versions.db
