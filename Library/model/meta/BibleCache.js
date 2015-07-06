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
* These tests were done when IO was file.  They need to be redone.
*
* This class does not yet have a means to remove old entries from cache.  
* It is possible that DB access is fast enough, and this is not needed.
* GNG July 5, 2015
*/
function BibleCache(collection) {
	this.collection = collection;
	this.chapterMap = {};
	this.parser = new USXParser();
	Object.freeze(this);
}
BibleCache.prototype.getChapter = function(reference, callback) {
	var that = this;
	var chapter = this.chapterMap[reference.nodeId];
	
	if (chapter !== undefined) {
		callback(chapter);
	} else {
		var statement = 'select xml from codex where book=? and chapter=?';
		var values = [ reference.book, reference.chapter ];
		this.collection.get(statement, values, function(row) {
			if (row instanceof IOError) {
				console.log('found Error', row);
				callback(row);
			} else {
				chapter = that.parser.readBook(row.xml);
				that.chapterMap[reference.nodeId] = chapter;
				callback(chapter);
			}
		});
	}
};

