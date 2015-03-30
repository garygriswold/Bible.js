/**
* This class writes XML node objects to a string array.  It's purpose is to enable
* a symmetric test where data that is read using XMLReader is written back out
* using XMLWriter to prove that the reading process worked correctly.
*/
"use strict";

function XMLWriter() {
	this.result = [];
	Object.seal(this);
};
XMLWriter.prototype.write = function(nodeType, nodeValue) {
	switch(nodeType) {
		case XMLNodeType.ELE_OPEN:
			this.result.push('<', nodeValue);
			break;
		case XMLNodeType.ATTR_NAME:
			this.result.push(' ', nodeValue, '=');
			break;
		case XMLNodeType.ATTR_VALUE:
			this.result.push('"', nodeValue, '"');
			break;
		case XMLNodeType.ELE_END:
			this.result.push('>');
			break;
		case XMLNodeType.WHITESP:
			this.result.push(nodeValue);
			break;
		case XMLNodeType.TEXT:
			this.result.push(nodeValue);
			break;
		case XMLNodeType.ELE_EMPTY:
			this.result.push(' />');
			break;
		case XMLNodeType.ELE_CLOSE:
			this.result.push('</', nodeValue, '>');
			break;
		case XMLNodeType.PROG_INST:
			this.result.push(nodeValue);
			break;
		case XMLNodeType.END:
			break;
		default:
			throw new Error('The XMLNodeType ' + nodeType + ' is unknown in XMLWriter');
	}
};
XMLWriter.prototype.close = function() {
	return(this.result.join(''));
};