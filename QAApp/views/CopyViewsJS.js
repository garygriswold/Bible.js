
function CopyViewsJS() {
	this.fs = require('fs');
}
CopyViewsJS.prototype.copy = function(sourceDir, targetFile) {
	var that = this;
	var result = [];
	this.readDirs(sourceDir, function(fileList) {
		console.log(fileList);
		for (var i=0; i<fileList.length; i++) {
			var filename = fileList[i];
			console.log('READ', filename);
			that.readFile(filename, function(file) {
				var code = that.extractCode(file);
				//console.log(code);
				var name = that.extractId(code);
				result.push("var " + name + " = '" + code.trim() + "';");
				if (result.length >= fileList.length) {
					that.writeViewFile(targetFile, result.join('\n\n'));
				}
			});
		}
	});
};
CopyViewsJS.prototype.readDirs = function(path, callback) {
	this.fs.readdir(path, function(err, fileList) {
		result = [];
		if (err) {
			console.error('ERROR in CopyViewsJS.readDirs', err);
			callback(result);
		} else {
			for (var i=0; i<fileList.length; i++) {
				var file = fileList[i];
				if (file.indexOf('View.html') > -1) {
					result.push(file);
				}
			}
			callback(result);
		}
	});	
};
CopyViewsJS.prototype.readFile = function(filename, callback) {
	this.fs.readFile(filename, { encoding: 'utf8'}, function(err, data) {
		if (err) {
			console.error('ERROR in CopyViewsJS.readFile', err);
			callback();
		} else {
			callback(data);
		}
	});
};
CopyViewsJS.prototype.extractCode = function(file) {
	var startBody = file.indexOf('<body');
	if (startBody > -1) {
		var endStartBody = file.indexOf('>', startBody);
		if (endStartBody > -1) {
			var endBody = file.indexOf('</body>', endStartBody);
			if (endBody > -1) {
				return(file.substring(endStartBody + 1, endBody));
			}
		}
	}
	return('');
};
CopyViewsJS.prototype.extractId = function(code) {
	console.log(code.substr(0, 40));
	var startId = code.indexOf('id="');
	console.log('startId', startId);
	if (startId > -1) {
		var endId = code.indexOf('"', startId + 5);
		console.log('endId', endId);
		return(code.substring(startId + 4, endId));
	}
	return('');
};
CopyViewsJS.prototype.writeViewFile = function(destFile, content) {
	this.fs.writeFile(destFile, content, { encoding: 'utf8'}, function(err) {
		if (err) {
			console.error('ERROR in CopyViewsJS.writeViewFile', err);
		}
	});	
};


var copy = new CopyViewsJS();
copy.copy('./', '../www/ViewLibrary.js');


