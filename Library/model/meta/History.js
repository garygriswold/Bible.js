/**
* This class manages a queue of history items up to some maximum number of items.
* It adds items when there is an event, such as a toc click, a search lookup,
* or a concordance search.  It also responds to function requests to go back 
* in history, forward in history, or return to the last event.
*/
"use strict";

function History() {
	this.items = [];
	this.currentItem = null;
	this.writer = new NodeFileWriter('application');
	this.isFilled = false;
	var that = this;
	this.bodyNode = document.getElementById('appTop');
	this.bodyNode.addEventListener(BIBLE.TOC, function(event) {
		that.addEvent(event);	
	});
	this.bodyNode.addEventListener(BIBLE.SEARCH, function(event) {
		that.addEvent(event);
	});
	Object.seal(this);
};
History.prototype.fill = function(itemList) {
	this.items = itemList;
	this.isFilled = true;
};
History.prototype.addEvent = function(event) {
	var item = new HistoryItem(event.detail.id, event.type, event.detail.source);
	this.items.push(item);
	this.currentItem = this.items.length -1;
	if (this.items.length > 1000) {
		var discard = this.items.shift();
		this.currentItem--;
	}
	setTimeout(this.persist(), 3000);
};
History.prototype.size = function() {
	return(this.items.length);
};
History.prototype.back = function() {
	return(this.item(--this.currentItem));
};
History.prototype.forward = function() {
	return(this.item(++this.currentItem));
};
History.prototype.last = function() {
	this.currentItem = this.items.length -1;
	return(this.item(this.currentItem));
};
History.prototype.current = function() {
	return(this.item(this.currentItem));
};
History.prototype.item = function(index) {
	return((index > -1 && index < this.items.length) ? this.items[index] : 'JHN:1');
};
History.prototype.persist = function() {
	var filepath = 'usx/WEB/history.json'; // Temporary path, it must be stored in data directory
	this.writer.writeTextFile(filepath, this.toJSON(), function(filename) {
		if (filename.errno) {
			console.log('error writing history.json', filename);
		} else {
			console.log('History saved', filename);
		}
	});
};
History.prototype.toJSON = function() {
	return(JSON.stringify(this.items, null, ' '));
};

