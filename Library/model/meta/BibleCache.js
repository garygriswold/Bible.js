/**
* This class handles all request to deliver scripture.  It handles all passage display requests to display passages of text,
* and it also handles all requests from concordance search requests to display individual verses.
* It will deliver the content from cache if it is present.  Or, it will find the content in persistent storage if it is
* not present in cache.  All content retrieved from persistent storage is added to the cache.
*
* On May 3, 2015 some performance checks were done.  The time measurements where from a sample of 4, the memory from a sample of 1.
* 1) Read Chapter 11.2ms, 49K heap increase
* 2) Parse USX 6.0ms, 306K heap increase
* 3) Generate Dom 2.16ms, 85K heap increase
* These tests were done when IO was file.
*
* On Jul 21, 2015 some performance checks were done using SQLite as the datastore.
* 1) Read Chapter 4.4 ms, 4K heap increase
* 2) Parse USX 1.8 ms, still large heap increase
* 3) Generate Dom  1ms, still large heap increase
*
* On Jul 22, 2015 stored HTML in DB and changed to use that so there is less App processing
* 1) Read Chapter 2.0 ms
* 2) Assign using innerHTML 0.5 ms
* 3) Append 0.13 ms
*
* This class does not yet have a means to remove old entries from cache.  
* It is possible that DB access is fast enough, and this is not needed.
* GNG July 5, 2015
*/
function BibleCache(adapter) {
	this.adapter = adapter;
	this.chapterMap = {};
	this.parser = new USXParser();
	Object.freeze(this);
}
/** deprecated */
BibleCache.prototype.getChapterHTML = function(reference, callback) {
	var that = this;
	var chapter = this.chapterMap[reference.nodeId];
	if (chapter !== undefined) {
		callback(chapter);
	} else {
		this.adapter.getChapterHTML(reference, function(chapter) {
			if (chapter instanceof IOError) {
				console.log('Bible Cache found Error', chapter);
				callback(chapter);
			} else {
				that.chapterMap[reference.nodeId] = chapter;
				callback(chapter);
			}
		});
	}
};

// Before deleting be sure to move performance nots to CodexView


