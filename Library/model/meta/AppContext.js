/**
* BibleApp is a global object that contains pointers to all of the key elements of
* a user's session with the App.
*/
"use strict"

function AppContext() {
	this.tableContentsGUI = new TableContentsGUI();
	Object.freeze(this);
};


