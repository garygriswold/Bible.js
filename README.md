# Bible.js

The BibleApp is the source code for "Your Bible", which has been deployed in the Apple App Store, and the Google Play Store.  Deployment in the Microsoft Store or Amazon Store has not yet been scheduled.  More information about this app can be found on the website http://safebible.org

Objectives
----------

The key objective of this project is to have a Bible App that cannot be blocked by a repressive government or organization that wishes to interfere with reading the Bible, and further to prevent someone from monitoring who is using this App to read the Bible.  Further, this App insures the anonymity of its readers by not collecting any information about them, except their language and country.

A second objective was to build an app that could easily contain the Bible in many languages.  To accomplish this the App that does not require localization for any language.  It does this by pulling some words from the text of the Bible to reuse in the user interface, but primarily the user interface is iconic instead of text.

The App is designed to be extremely easy to use, so that it is useful to the very young, the very old, and people who only recently learned to read.  This objective is partly accomplished by limiting the features of the App to those that are essential.

In order to provide Bible readers with an experience similar to the Ethiopian official in Acts 8, the App will provide a way for readers to ask questions that will be answered by a person.  This is an experimental feature that can be turned on or off for each language depending upon the availability of qualified volunteer instructors.

License
-------

Public domain license using the MIT template.

Repository Structure
--------------------

Docs - This directory contains critical how-to instructions.

Library - This is the common javascript library.  Many projects contain a shell script that copies all of the files that they need from this Library.

Plugins - This contains the native code for various modules (frameworks in iOS).  They include: VideoPlayer, AudioPlayer, AWS (Amazon Web Services), and Utility, which is primarily Sqlite3.

Publisher - This project prepares copies of the Bible for publication.  It takes as input a Bible in USX format and produces a SQLite database of the content, concordance, and table of contents in the form needed by the App.

SafeBible - This directory contains the iOS and Android versions of the mobile App.

Server - This directory contains programs and scripts for woking with files stored in AWS S3. This includes Bible text and audio content, and analytics of the App's use.

UnitTests - This is various unit tests for the Javascript portion. of the App

Validation - This directory contains a number of scripts that test the correctness of the Bible database as produced by Publisher.

Versions - The project builds a database of information about versions of the Bible which can be downloaded by the App.  This database is included in the BibleApp.

