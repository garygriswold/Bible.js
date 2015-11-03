

function LoadVersions() {
	var DatabaseAdapter = require('./DatabaseAdapter');
	this.database = new DatabaseAdapter({filename: './Versions.db', verbose: false});
};
LoadVersions.prototype.create = function() {
	var that = this;
	this.database.create(function() {
		console.log('DONE CREATE');
		that.database.loadAll('data/Versions');
	});
};

var load = new LoadVersions();
load.create();
