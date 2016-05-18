/**
* This class is used to contain the fields about a version of the Bible
* as needed.
*/
function BibleVersion() {
	this.code = null;
	this.filename = null;
	this.userFilename = null;
	this.silCode = null;
	this.langCode = null;
	this.isQaActive = null;
	this.copyrightYear = null;
	this.versionAbbr = null;
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
			that.filename = 'WEB.db';
			that.userFilename = 'WEBUser.db';
			that.silCode = 'eng';
			that.langCode = 'en';
			that.isQaActive = 'F';
			that.copyrightYear = 'PUBLIC';
			that.versionAbbr = 'WEB';
			that.localLanguageName = 'English';
			that.localVersionName = 'World English Bible';
			that.ownerCode = 'EB';
			that.ownerName = 'eBible';
			that.ownerURL = 'www.eBible.org';
			that.introduction = null;
		} else {
			that.code = row.versionCode;
			that.filename = filename;
			var parts = filename.split('.');
			that.userFilename = parts[0] + 'User.db';
			that.silCode = row.silCode;
			that.langCode = row.langCode;
			that.isQaActive = row.isQaActive;
			that.copyrightYear = row.copyright;
			that.versionAbbr = row.versionAbbr;
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

