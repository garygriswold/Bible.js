# Bible.js
The BibleApp is currently under development.  The first deployments in the Apple, Google and Microsoft stores is expected later this year.

Objectives
----------

One key objective is to build an App that does not require localization for any language.  It does this by pulling some words from the text of the Bible to reuse in the user interface, but primarily the user interface is iconic instead of text.

The App is designed to be extremely easy to use, so that it is useful to the very young, the very old, and people who only recently learned to read.  This objective is partly accomplished by limiting the features of the App to those that are essential.

In order to provide Bible readers with an experience similar to the Ethiopian official in Acts 8, the App will provide a way for readers to ask questions that will be answered by a person.  This is an experimental feature that can be turned on or off for each language depending upon the availability of qualified volunteer instructors.

This App will provide the ability for peer to peer installation using NFC, and for operating systems that will not permit this, in the future there will be an ePub3 (ebook) version of the App.  This will be done so that it is possible for people to share the Bible in locations of the world where governments are hostile to Christianity.

The App will use Ethnologic information to present each user with a limited number of languages that is used in their geographic area.

License
-------

Public domain license using the MIT template.

Repository Structure
--------------------

Library - This is the common javascript library.  Each project contains a shell script that copies all of the files that it needs from Library.

BibleAppNW - This is a Node/WebKit App, which will run as a local (not browser) application on desktop computers.  This is where the original development is being done, because of the ease of development in this environment.

BibleAppXDK - This is a mobile Cordova version of the App, developed using the Intel XDK development environment.  Real work has not yet been done in this environment.

UnitTestCSS1 - This is an early unit test project, which will be deleleted when other test programs are completed.

