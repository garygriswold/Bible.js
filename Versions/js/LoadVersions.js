/*
* This class is no longer, used and has been replaced by raw SQL input.
* It is included here just in case, I later want to use this program which
* loads data from CSV files.
*/
function LoadVersions() {
	var DatabaseAdapter = require('./DatabaseAdapter');
	this.database = new DatabaseAdapter({filename: './Versions.db', verbose: false});
};
LoadVersions.prototype.create = function() {
	var that = this;
	this.database.create(function() {
		console.log('DONE CREATE');
		that.database.loadAll('data/Versions', function() {
			that.database.loadIntroductions('data/VersionIntro', function() {
				that.database.close();
				console.log('SUCCESSFULLY CREATED Versions.db');
			});
		});
	});
};

var load = new LoadVersions();
load.create();
