/**
* This is a node program that is executed at compile time by RunApp.sh or RunDevice.sh
* It reads the config.xml file and finds the version code, and outputs a short script that
* contains that code.
*/
"use strict";
var bibleAppConfigWriter = {
	process: function(outputFilename) {
		var that = this;
		that.readConfig(function(contents) {
			var versionCode = that.parseConfig(contents);
			console.log("Found versionCode: ", versionCode);
			that.writeBibleAppConfig(outputFilename, versionCode);
		});
	},
	readConfig: function(callback) {
		var fs = require('fs');
		var configFile = process.env.HOME + '/ShortSands/BibleApp/YourBible/config.xml';
		console.log("READ config: " + configFile);
		fs.readFile(configFile, 'utf8', function (error, data) {
			if (error) {
				console.log(error);
				callback("");
  			} else {
	  			callback(data)
  			}
		});		
	},
	parseConfig: function(contents) {
	  	var line2 = contents.indexOf("widget");
		var start = contents.indexOf("version=", line2) + 8;
		var quote = contents.charAt(start);
		var end = contents.indexOf(quote, start + 1);
		return(contents.substring(start, end + 1));
	},
	writeBibleAppConfig: function(outputFilename, versionCode) {
		var contents = "\t\tvar BibleAppConfig = {versionCode: " + versionCode + "};\n";
		contents += "\t\tconsole.log('BibleAppConfig.versionCode = ', BibleAppConfig.versionCode);\n";
		var fs = require('fs');
		fs.writeFile(outputFilename, contents, 'utf8', function(error) {
			if (error) {
				console.log(error);
			}
		});
	}
};





if (process.argv.length < 3) {
	console.log('Usage: node ../Library/util/BibleAppConfigWriter.js outputFile');
	process.exit(1);
} else {
	var outputFilename = process.argv[2];
	console.log('Output File: ' + outputFilename);
	bibleAppConfigWriter.process(outputFilename);
}
