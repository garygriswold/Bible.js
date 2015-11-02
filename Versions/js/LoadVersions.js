

function LoadVersions() {
	var DatabaseAdapter = require('./DatabaseAdapter');
	this.database = new DatabaseAdapter({filename: './Versions.db', verbose: false});
};
LoadVersions.prototype.create = function() {
	this.database.create(function(error, rowCount) {
		if (error) { 
			console.log('ERROR', error);
		} else {
			console.log('RESULTS', rowCount);
		}
	});
};

var load = new LoadVersions();
load.create();
