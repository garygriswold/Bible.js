Bible App Test Plan
===================

This documents manual procedures for testing the user interface of the BibleApp.
Gary Griswold, July 29, 2015

StatusBarView
-------------

CodexView
---------

TableContentsView
-----------------

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
	1. Temporarily change MAX_HISTORY to 5.  Exceed 5 and verify that delete is occuring.
	2. Change MAX_HISTORY back to original value.


QuestionsView
-------------
