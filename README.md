# Bible.js
The BibleApp is currently under development.  The first deployments in the Apple, Google and Microsoft stores is expected later this year.

Objectives
----------

One key objective is to build an App that does not require localization for any language.  It does this by pulling some words from the text of the Bible to reuse in the user interface, but primarily the user interface is iconic instead of text.

The App is designed to be extremely easy to use, so that it is useful to the very young, the very old, and people who only recently learned to read.  This objective is partly accomplished by limiting the features of the App to those that are essential.

In order to provide Bible readers with an experience similar to the Ethiopian official in Acts 8, the App will provide a way for readers to ask questions that will be answered by a person.  This is an experimental feature that can be turned on or off for each language depending upon the availability of qualified volunteer instructors.

This App will provide the ability for peer to peer installation using NFC, and for operating systems that will not permit this, in the future there will be an ePub3 (ebook) version of the App.  This will be done so that it is possible for people to share the Bible in locations of the world where governments are hostile to Christianity.

The App will use Ethnologic information to present each user with a limited number of languages that are used in their geographic area.

License
-------

Public domain license using the MIT template.

Repository Structure
--------------------

Library - This is the common javascript library.  Most projects contain a shell script that copies all of the files that they need from this Library.

Publisher - This project prepares copies of the Bible for publication.  It takes as input a USX package from the Digital Bible Library and produces a SQLite database of the content, concordance, and table of contents in the form needed by the App.

BibleAppNW - This is a Node/WebKit App, which will run as a local (not browser) application on desktop computers.  This is where the original development is being done, because of the ease of development in this environment.

BibleAppCLI - This is a mobile Cordova version of the App.  This version of the App runs on mobile devices. It currently runs well on Android, but awkwardly on iOS.

QAApp - This is a web App that is used by instructors to answer questions of students.  It is written in a single-page architecture so that it could be rewritten as a mobile App.

Server - This is a project for the server, which will deliver copies of the Bible and handle the delivery of student questions and Instructor answers.

UnitTest - This is a repository of UnitTests for various parts of the system.

