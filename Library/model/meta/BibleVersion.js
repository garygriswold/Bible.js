/**
* This class is used to contain the fields about a version of the Bible
* as needed.
*/
function BibleVersion() {
	this.code = null;
	this.filename = null;
	this.silCode = null;
	this.isQaActive = null;
	this.copyrightYear = null;
	this.localLanguageName = null;
	this.localVersionName = null;
	this.ownerCode = null;
	this.ownerName = null;
	this.ownerURL = null;
	Object.seal(this);
}
BibleVersion.prototype.fill = function(filename, callback) {
	var that = this;
	var versionsAdapter = new VersionsAdapter();
	versionsAdapter.selectVersionByFilename(filename, function(row) {
		if (row instanceof IOError) {
			that.code = 'WEB';
			that.filename = 'WEB.db1';
			that.silCode = 'eng';
			that.isQaActive = 'F';
			that.copyrightYear = 'PUBLIC';
			that.localVersionName = 'World English Bible';
			this.ownerCode = 'EB';
			that.ownerName = 'eBible';
			that.ownerURL = 'eBible.org';
		} else {
			that.code = row.versionCode;
			that.filename = filename;
			that.silCode = row.silCode;
			that.isQaActive = row.isQaActive;
			that.copyrightYear = row.copyrightYear;
			that.localLanguageName = row.localLanguageName;
			that.localVersionName = row.localVersionName;
			that.ownerCode = row.ownerCode;
			that.ownerName = row.ownerName;
			that.ownerURL = row.ownerURL;
		}
		callback();
	});
};

