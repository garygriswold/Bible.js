/**
* This class contains a text string as parsed from a USX Bible file.
*/
"use strict";

function Text(text) {
	this.text = text;
	Object.freeze(this);
};
Text.prototype.tagName = 'text';
Text.prototype.buildUSX = function(result) {
	result.push(this.text);
}
