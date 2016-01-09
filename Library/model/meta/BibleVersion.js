/**
* This class is used to contain the fields about a version of the Bible
* as needed.
*/
function BibleVersion() {
	console.log('start version cons');
	this.code = null;
	this.filename = null;
	this.silCode = null;
	this.isQaActive = null;
	console.log('end version cons');
	Object.seal(this);
	console.log('end version seal');
}
BibleVersion.prototype.fill = function(filename, callback) {
	console.log('start fill', filename);
	var that = this;
	var versionsAdapter = new VersionsAdapter();
	versionsAdapter.selectVersionByFilename(filename, function(versionObj) {
		console.log('found', versionObj);
		if (versionObj instanceof IOError) {
			that.code = 'WEB';
			that.filename = 'WEB.db1';
			that.silCode = 'eng';
			that.isQaActive = 'F';
		} else {
			that.code = versionObj.versionCode;
			that.filename = filename;
			that.silCode = versionObj.silCode;
			that.isQaActive = versionObj.isQaActive;
		}
		console.log('this', this);
		callback();
	});
};