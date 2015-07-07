/**
* This class contains the details of a single history event, such as
* clicking on the toc to get a chapter, doing a lookup of a specific passage
* or clicking on a verse during a concordance search.
*/
function HistoryItem(nodeId, source, search, timestamp) {
	this.nodeId = nodeId;
	this.source = source;
	this.search = search;
	this.timestamp = (timestamp) ? new Date(timestamp) : new Date();
	Object.freeze(this);
}