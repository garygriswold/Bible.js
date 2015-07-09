/**
* This class manages a queue of history items up to some maximum number of items.
* It adds items when there is an event, such as a toc click, a search lookup,
* or a concordance search.  It also responds to function requests to go back 
* in history, forward in history, or return to the last event.
*/
//var MAX_HISTORY = 20;

function History(collection) {
	this.collection = collection;
	this.items = [];
	this.isFilled = false;
	this.isViewCurrent = false;
	Object.seal(this);
}
History.prototype.fill = function(callback) {
	var that = this;
	this.items.splice(0);
	this.collection.selectAll(function(results) {
		if (results instanceof IOError) {
			callback();
		} else {
			for (var i=0; i<results.rows.length; i++) {
				var row = results.rows.item(i);
				var ref = new Reference(row.book, row.chapter, row.verse);
				var hist = new HistoryItem(ref.nodeId, row.source, row.search, row.timestamp);
				console.log('HISTORY', hist, hist.timestamp.toISOString());
				that.items.push(hist);
			}
			that.isFilled = true;
			that.isViewCurrent = false;
		}
		callback();
	});
};
History.prototype.addEvent = function(event) {
	var itemIndex = this.search(event.detail.id);
	if (itemIndex >= 0) {
		this.items.splice(itemIndex, 1);
	}
	var item = new HistoryItem(event.detail.id, event.type, event.detail.source);
	this.items.push(item);
	if (this.items.length > MAX_HISTORY) {
		var discard = this.items.shift();
	}
	this.isViewCurrent = false;
	
	// I might want a timeout to postpone this until after animation is finished.
	var timestampStr = item.timestamp.toISOString();
	var ref = new Reference(item.nodeId);
	var values = [ timestampStr, ref.book, ref.chapter, ref.verse, item.source, item.search ];
	this.collection.replace(values, function(err) {
		if (err instanceof IOError) {
			console.log('replace error', JSON.stringify(err));
		}
	});
};
History.prototype.search = function(nodeId) {
	for (var i=0; i<this.items.length; i++) {
		var item = this.items[i];
		if (item.nodeId === nodeId) {
			return(i);
		}
	}
	return(-1);
};
History.prototype.size = function() {
	return(this.items.length);
};
History.prototype.last = function() {
	return(this.item(this.items.length -1));
};
History.prototype.item = function(index) {
	return((index > -1 && index < this.items.length) ? this.items[index] : new HistoryItem('JHN:1'));
};
History.prototype.lastConcordanceSearch = function() {
	for (var i=this.items.length -1; i>=0; i--) {
		var item = this.items[i];
		if (item.search && item.search.length > 0) { // also trim it
			return(item.search);
		}
	}
	return('');
};
History.prototype.toJSON = function() {
	return(JSON.stringify(this.items, null, ' '));
};

