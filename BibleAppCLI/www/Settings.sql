/**
* This file contains the installation script for Settings.db, which replaces LocalStorage.
*
*/

1) cd BibleAppCLI/www

2) create the database:
> sqlite3 Settings.db

3) CREATE TABLE Settings(name TEXT PRIMARY KEY NOT NULL, value TEXT NULL);

4) CREATE TABLE Installed(version TEXT PRIMARY KEY NOT NULL, filename TEXT NOT NULL, timestamp TEXT NOT NULL);

5) It is ready to use.

6) Copy it to BibleAppNW also as follows:
> cp Settings.db "$HOME/Library/Application Support/BibleAppNW/databases/file__0/3" 