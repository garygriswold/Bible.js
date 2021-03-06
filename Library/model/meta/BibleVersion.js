/**
* This class is used to contain the fields about a version of the Bible
* as needed.
*/
function BibleVersion(langPrefCode, countryCode) {
	this.langPrefCode = langPrefCode;
	this.countryCode = countryCode;
	this.code = null;
	this.filename = null;
	this.silCode = null;
	this.langCode = null;
	this.direction = null;
	this.hasHistory = null;
	this.isQaActive = null;
	this.versionAbbr = null;
	this.localLanguageName = null;
	this.localVersionName = null;
	this.ownerCode = null;
	this.ownerName = null;
	this.ownerURL = null;
	this.copyright = null;
	this.bibleVersion = null;
	this.introduction = null;
	this.audioBookIdList = null;
	Object.seal(this);
}
BibleVersion.prototype.fill = function(filename, callback) {
	var that = this;
	var versionsAdapter = new VersionsAdapter();
	versionsAdapter.selectVersionByFilename(filename, function(row) {
		if (row instanceof IOError) {
			console.log('IOError selectVersionByFilename', JSON.stringify(row));
			that.code = 'WEB';
			that.filename = 'WEB.db';
			that.silCode = 'eng';
			that.langCode = 'en';
			that.direction = 'ltr';
			that.hasHistory = true;
			that.isQaActive = 'F';
			that.versionAbbr = 'WEB';
			that.localLanguageName = 'English';
			that.localVersionName = 'World English Bible';
			that.ownerCode = 'EBIBLE';
			that.ownerName = 'eBible.org';
			that.ownerURL = 'www.eBible.org';
			that.copyright = 'World English Bible (WEB), Public Domain, eBible.';
			that.bibleVersion = null;
		} else {
			that.code = row.versionCode;
			that.filename = filename;
			that.silCode = row.silCode;
			that.langCode = row.langCode;
			that.direction = row.direction;
			that.hasHistory = (row.hasHistory === 'T');
			that.isQaActive = row.isQaActive;
			that.versionAbbr = row.versionAbbr;
			that.localLanguageName = row.localLanguageName;
			that.localVersionName = row.localVersionName;
			that.ownerCode = row.ownerCode;
			that.ownerName = row.localOwnerName;
			that.ownerURL = row.ownerURL;
			that.copyright = row.copyright;
			that.bibleVersion = row.bibleVersion;
		}
		versionsAdapter.selectIntroduction(that.code, function(result) {
			if (result instanceof IOError) {
				that.introduction = null;
			} else {
				that.introduction = result;
			}
			callback();
		});
	});
};
BibleVersion.prototype.hasAudioBook = function(bookId) {
	if (this.audioBookIdList !== null && this.audioBookIdList.length > 2) {
		var index = this.audioBookIdList.indexOf(bookId);
		return(index >= 0);
	} else {
		return false;
	}
};

