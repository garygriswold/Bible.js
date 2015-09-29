#!/bin/sh

cp ../Server/www/AutoTestDatabase.db ../Server/www/TestDatabase.db

sqlite3 ../Server/www/TestDatabase.db < ServerTestData.sql