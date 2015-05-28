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
*/
function BibleCache(types) {
	this.types = types;
	this.chapterMap = {};
	this.reader = new NodeFileReader(types.location);
	this.parser = new USXParser();
	Object.freeze(this);
}
BibleCache.prototype.getChapter = function(reference, callback) {
	var that = this;
	var chapter = this.chapterMap[reference.nodeId];
	
	if (chapter !== undefined) {
		callback(chapter);
	} else {
		var filepath = this.types.getAppPath(reference.path());
		this.reader.readTextFile(filepath, function(data) {
			if (data.errno) {
				console.log('BibleCache.getChapter ', JSON.stringify(data));
				callback(data);
			} else {
				chapter = that.parser.readBook(data);
				that.chapterMap[reference.nodeId] = chapter;
				callback(chapter);				
			}
		});
	}
};
