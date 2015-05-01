/**
* This class checks for the presence of each assets that is required.
* It should be expanded to check for the correct version of each asset as well, 
* once assets are versioned.
*/
"use strict";

function AssetChecker(types) {
	this.types = types;
};
AssetChecker.prototype.check = function(callback) {
	var that = this;
	var result = new AssetType(this.types.location, this.types.versionCode);
	var reader = new NodeFileReader(that.types.location);
	var toDo = this.types.toBeDoneQueue();
	checkExists(toDo.shift());

	function checkExists(filename) {
		if (filename) {
			var fullPath = that.types.getPath(filename);
			console.log('checking for ', fullPath);
			reader.fileExists(fullPath, function(stat) {
				if (stat.errno) {
					if (stat.code === 'ENOENT') {
						console.log('check exists ' + filename + ' is not found');
						result.mustDoQueue(filename);
					} else {
						console.log('check exists for ' + filename + ' failure ' + JSON.stringify(stat));
					}
				} else {
					// Someday I should check version when check succeeeds.  When version is known.
					console.log('check succeeds for ', filename);
				}
				checkExists(toDo.shift());
			});
		} else {
			callback(result);
		}
	}
};
