/**
* This class is used to contain the fields about a version of the Bible
* as needed.
*/
function BibleVersion() {
	this.code = null;
	this.filename = null;
	this.userFilename = null;
	this.silCode = null;
	this.isQaActive = null;
	this.copyrightYear = null;
	this.localLanguageName = null;
	this.localVersionName = null;
	this.ownerCode = null;
	this.ownerName = null;
	this.ownerURL = null;
	this.introduction = null;
	Object.seal(this);
}
BibleVersion.prototype.fill = function(filename, callback) {
	var that = this;
	var versionsAdapter = new VersionsAdapter();
	versionsAdapter.selectVersionByFilename(filename, function(row) {
		if (row instanceof IOError) {
			that.code = 'WEB';
			that.filename = 'WEB.db1';
			that.userFilename = 'WEBUser.db';
			that.silCode = 'eng';
			that.isQaActive = 'F';
			that.copyrightYear = 'PUBLIC';
			that.localVersionName = 'World English Bible';
			this.ownerCode = 'EB';
			that.ownerName = 'eBible';
			that.ownerURL = 'eBible.org';
			that.introduction = null;
		} else {
			that.code = row.versionCode;
			that.filename = filename;
			var parts = filename.split('.');
			that.userFilename = parts[0] + 'User.db';
			that.silCode = row.silCode;
			that.isQaActive = row.isQaActive;
			that.copyrightYear = row.copyrightYear;
			that.localLanguageName = row.localLanguageName;
			that.localVersionName = row.localVersionName;
			that.ownerCode = row.ownerCode;
			that.ownerName = row.ownerName;
			that.ownerURL = row.ownerURL;
			that.introduction = row.introduction;
		}
		callback();
	});
};

