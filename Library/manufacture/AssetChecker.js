/**
* This class checks for the presence of each assets that is required.
* It should be expanded to check for the correct version of each asset as well, 
* once assets are versioned.
*/
"use strict";

function AssetChecker() {
};
AssetChecker.prototype.check = function(types, callback) {
	var that = this;
	var result = new AssetType(types.location, types.versionCode);
	var toDo = types.toBeDoneQueue();
	checkExists(toDo.shift());

	function checkExists(filename) {
		if (filename) {
			var reader = new NodeFileReader(types.location);
			var fullPath = 'usx/' + types.versionCode + '/' + filename; // this needs to be somewhere central
			console.log('checking for ', fullPath);
			reader.fileExists(fullPath, function(stat) {
				if (stat instanceof Error) {
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
