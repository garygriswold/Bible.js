/**
* This class contains a Note from a USX parsed Bible
*/
"use strict";

function Note(caller, style) {
	this.caller = caller;
	this.style = style;
	Object.freeze(this);
};
Note.prototype.toUSX = function() {
	return("{ name: 'note',\n  attributes:\n  { style: '" + this.style + "', caller: '" + this.caller + "' },\n  isSelfClosing: false }");
}