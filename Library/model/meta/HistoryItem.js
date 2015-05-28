/**
* This class contains the details of a single history event, such as
* clicking on the toc to get a chapter, doing a lookup of a specific passage
* or clicking on a verse during a concordance search.
*/
"use strict";

function HistoryItem(key, source, search) {
	this.key = key;
	this.source = source;
	this.search = search;
	this.timestamp = new Date();
	Object.freeze(this);
}