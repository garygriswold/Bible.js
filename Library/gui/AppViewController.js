/**
* BibleApp is a global object that contains pointers to all of the key elements of
* a user's session with the App.
*/
"use strict"

function AppViewController() {
	this.tableContentsView = new TableContentsView();
	Object.freeze(this);
};


