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

Publisher - This project prepares copies of the Bible for publication.  It takes as input a USX package from the Digital Bible Library and produces a SQLite database of the content, concordance, and table of contents in the form needed by the App.

Validation - This directory contains a number of scripts that test the correctness of the Bible database as produced by Publisher.

BibleAppNW - This is a Node/WebKit App, which will run as a local (not browser) application on desktop computers.  This is where the original development is often done, because of the ease of development in this environment.

YourBible - This is a mobile Cordova version of the App.  This version of the App runs on mobile devices. It currently runs well on Android and iOS.

QAApp - This is a web App that is used by instructors to answer questions of students.  It is written in a single-page architecture so that it could be rewritten as a mobile App.  This feature has not been deployed in production

Server - This is a project for the server, which will deliver copies of the Bible and handle the delivery of student questions and Instructor answers.  The Bible delivery capability of this has been moved to cloudfront.net.  The student question and instructor answer feature has not been put into production.
	aws/lambda - Contains the Amazon Web Services Lambda functions that are currently in production.
	www - Contains a node application server which was in production in the past, but has been retired.

UnitTest - This is a repository of UnitTests for various parts of the system.

Versions - The project builds a database of information about versions of the Bible which can be downloaded by the App.  This database is included in the BibleApp.

