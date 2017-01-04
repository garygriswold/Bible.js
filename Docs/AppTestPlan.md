Bible App Test Plan
===================

This documents manual procedures for testing the user interface of the BibleApp.
Gary Griswold, January 1, 2016
Revised Aug 9, 2016
Revised Nov 11, 2016
Revised Dec 30, 2016

App Icon
--------

	1. Appearance should be consistent, or at least acceptable on all devices.
	2. Name should be fully visible on all devices. (I think 13 chars max).
	3. The name should display locally for each language.
	
Splash Screen
-------------

	1. Should display properly on all devices.
	2. Startup should display a minimum of white screen and no black.

HeaderView
----------

	1. Must give room to status bar on all devices.
	2. Each button when pushed must present the corresponding page.
	3. Chapter label must update at correct times during scrolling.
	
TableContentsView
-----------------

	1. Present properly when button is pushed.
	2. First display should be at top with Genesis.
	3. Subsequent displays should display last position with chapters open.
	4. Chapter names, such as 1 Thessalonians, should not wrap.
	5. When clicking on a book, it displays the chapters and all should be visible.
	6. The chapter boxes should be well centered in the page.
	7. When clicking on the chapter, it should display properly positioned.
	
App Startup
-----------

	1. First install the production version on the device.
	2. Download or install a few versions.
	3. Change version to something other than default version.
	4. Install the App over the wire with a higher version number.
	5. It should start with the prior selected version, not the default version.
	6. Verify in log that Settings database is created with Settings, Installed, History and Questions
	7. Verify in log that each version installed in www was removed from databases
	8. Change version, and observe the delay caused by copying the Bible database
	9. Change version to one that has already been started, and observe the quick change.
	10. Somehow test condition that Version is listed, but not actually available.  App should not fail, but just fail to load version.
	
Startup Download
----------------

	1. Test that already used version bypasses all download logic.
	2. Test that locale is determined for user
	3. Test that default language for versions is found.
	4. Test that ERV-ENG.db is used when no default is found.
	5. Test that download is bypassed if version is already present on device
	6. Test that download succeeds if version is not already present on device
	7. Test that lightening cloud is used if there is a failure in download.
	8. Test that download cloud reappears after leaving and returning to VersionView
	
User Download
-------------

	1. Do a fresh install with only the default version.
	2. Verify that a file can be downloaded when version is selected.
	3. Restart the App with a version change.
	4. Verify that a file can be downloaded when version is selected.
	5. Restart the App with no version change.
	6. Verify that a file can be downloaded when version is selected.
	7. Test Download of Each Version, or each new Version
	8. Do clean install, but change locale to verify that it will do install at point of install.
	
AWS Server
----------

	1. Check that shortlog and shortsands-xx-drop contain no logs.
	2. Verify that cloudlog and shortsands-xx-log contains a log entry for each download.

CodexView
---------

	1. Display requested chapter at top.
		a. Try with large font size.
		b. Try with small font size.
		c. Try Genesis 1.
		d. Try Revelation 22.
	2. Scroll back should show chapter.
	3. Scroll forward should work continuously with little or no stopping.
	4. Scroll backward will sometimes stop at the beginning of a chapter, and then continue.
	
FootNotes
---------

	Compare the following complex footnotes in KJVPD to insure that they are complete
	1. EXO 17:15
	2. EXO 32:11
	3. EXO 32:29
	4. DEU 32:27
	5. JOS 23:9
	6. JUD 6:24
	
SearchView
----------

	1. Enter and invalid word presents a blank page.
	2. Enter a valid word presents up to 3 uses per book and an ellipsis if there are more.
	3. Enter a valid word or series of words with leading and trailing spaces.
	4. The verses contain the search words in bold.
	5. Selecting a word, presents that passage, scrolled to that word.
	6. Clicking back on the spyglass takes one back to the search box, and place where one left off.
	7. Clicking on the ellipsis, presents all of the verses in that chapter.
	8. Doing a search on the word 'a' does not crash the App.
	9. Typing in a reference takes one directly there.
	10. Typing in multiple words does search for the exact phrase.

HistoryView
-----------

*LastItem*
	1. Startup with an empty history table, the App should start at John 1.
	2. Startup with one item in the history table, the App should start with it.
	3. Startup with more than one item in the history table, the App should start with the most recent.

*lastSearchItem*
	1. Startup with an empty history table, click search, the search field should be empty.
	2. Startup with a non-empty history table, but no search items, click search, same result.
	3. Also on item above the search parameter should be null, not undefined.
	4. Add one search item, and test that it is used on next startup.

*history buttons*
	1. Startup with empty history table, history should present empty.
	2. Add one item to history, is should display on next pan-right for history.
	3. Add another from table of contents, it should display above.
	4. Add two from search, they should each display in the correct sequence.
	5. Make multiple requests without adding to history, it should not do select.
	6. Restart program, history should be identical.

*update history*
	1. Click on history tab, and see that it becomes the top tag.
	2. Click on top tab, it should re-present the chapter.

*cleanup*
	1. Temporarily change MAX_HISTORY to 5.  Exceed 5 and verify that delete is occurring.
	2. Change MAX_HISTORY back to original value.


QuestionsView
-------------

	1. On first start, Acts 8 should be presented question and answer.
	2. On first present, Reference and Question box should present.
	3. Entry of Question should transmit to server, and be presented as Question.
	4. Entry of Question should be stored in database on server.
	5. Questions should appear on the Q&A App.
	6. Answers should appear in App once answered.
	7. Only most recent answer appears.
	8. Other answers appear when the question is clicked.
	
SettingsView
------------

	1. Font Size control should have a start position of ?
	2. Font Size control should move with easily.
	3. John 3:16 text should resize as the thumb is moved.
	4. Other text on the page should resize when the thumb is released.
	5. The last font size used should be saved for the next time the app is started cold.
	6. The default font size and the range of font sizes should be reasonable on all devices.

VersionsView
------------

	1. On first view, the versions should be a list of country names and flags.
	2. Each country name should be in the language that is dominant for that country.
	3. Clicking on a country name or flag should present a list of languages.
	4. The language bars should contain language name, scope, and copyright owner.
	5. Each language bar should contain an icon for status, cloud for to be downloaded, book for has been downloaded, and checkmark for download finished.
	6. Clicking on an already download book should make it active.
	7. Clicking on a to be downloaded icon should download it and make it active.
	
Server Test
-----------

	1. Run a test script that downloads each version of the Bible from each region.
	2. Run log download and verify that each request has been recorded in the log.
	

AppUpdater Unit Test Plan
=========================
AppUpdater is complex, and needs a significant unit test.  This plan covers the following cases:

	1. Bible in www, not used, version 1.1 				(Test 1 NMV)
	2. Bible in www, not used, version new 				(Test 1 ERV-ENG)
	3. Bible in www, used, not current, version 1.1 	(Test 2 ERV-ARB)
	4. Bible in www, used, not current, version new 	(Test 3 ERV-HUN)
	5. Bible in www, used and current, version 1.1		(Test 2 NMV)
	6. Bible in www, used and current, version new		(Test 3 ERV-ENG)
	7. Bible not downloaded, version 1.1				(Test 1 KJVPD)
	8. Bible not downloaded, version new				(Test 1 ERV-SPA)
	9. Bible downloaded, not current, version 1.1		(Test 2 WEB)
	10. Bible downloaded, not current, version new		(Test 3 ERV-AWA)
	11. Bible downloaded and current, version 1.1		(Test 4 KJVPD)
	12. Bible downloaded and current, version new		(Test 3 ERV-AWA)
	
Setup For Test
--------------

	1. www contains: ERV-ENG, ERV-ARB, NMV.
	2. make certain version is 1.1 in Versions.Identity table for all Bibles.
	3. update Identity set bibleVersion = '1.1';
	4. set version in config.xml to a starting value.
	5. delete the App off the device.
	6. do a fresh install of the App
	
	Expect Installed: ERV-ARB 1.1, ERV-ENG 1.1, NMV 1.1
	Expect in Storage: Settings.db, Versions.db
	Expect in View: ERV-ARB, ERV-ENG checked, NMV
	
Test 1
------

	1. download ERV-BEN
	2. make current ERV-ARB
	3. increment config.xml version
	4. change ERV-* versions to 1.2 in Versions.db
	5. update Identity set bibleVersion = '1.2' where versionCode like 'ERV-%';
	6. install update of App
	
	Expect Installed: ERV-ARB 1.2, ERV-ENG 1.2, NMV 1.1
	Expect in Storage: Settings.db, Versions.db, ERV-BEN
	Expect in View: ERV-ARB checked, ERV-ENG, NMV
	
Test 2
------

	1. download ERV-HUN
	2. download WEB
	3. make current NMV
	4. increment config.xml version
	5. change ERV-* versions to 1.3 in Versions.db
	6. update Identity set bibleVersion = '1.3' where versionCode like 'ERV-%';
	7. install update of App
	
	Expect Installed: ERV-ARB 1.3, ERV-ENG 1.3, NMV 1.1, WEB 1.1
	Expect in Storage: Settings.db, Versions.db, ERV-BEN, ERV-HUN, NMV, WEB
	Expect in View: ERV-ARB, ERV-ENG, NMV checked, WEB
	
Test 3
------

	1. download ERV-AWA
	2. leave current
	3. increment config.xml version
	4. change ERV-* versions to 1.4 in Versions.db
	5. update Identity set bibleVersion = '1.4' where versionCode like 'ERV-%';
	6. install update of App
	
	Expect Installed: ERV-ARB 1.4, ERV-ENG 1.4, NMV 1.1, WEB 1.1
	Expect in Storage: Settings.db, Versions.db, ERV-AWA, ERV-BEN, ERV-HUN, NMV, WEB
	Expect in View: ERV-ARB, ERV-AWA checked, ERV-ENG, NMV, WEB
	
Test 4
------

	1. download KJVPD
	2. leave current
	3. increment config.xml version
	4. change ERV-* versions to 1.5 in Versions.db
	5. update Identity set bibleVersion = '1.5' where versionCode like 'ERV-%';
	6. install update of App
	
	Expect Installed: ERV-ARB 1.5, ERV-ENG 1.5, KJVPD 1.1, NMV 1.1, WEB 1.1
	Expect in Storage: Settings.db, Versions.db, ERV-AWA, ERV-BEN, ERV-HUN, KJVPD, NMV, WEB
	Expect in View: ERV-ARB, ERV-ENG, KJVPD checked, NMV, WEB




