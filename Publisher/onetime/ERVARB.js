/**
* The ERV-ARB version contained tags \nd2 .. \nd2*, which are not valid and would not process
* in ParaText.  BLI advised that the correct format for these was bold, and so \bd .. \bd* was
* a possible substitute.  And there was only one occurrance of \bd already in that version.
* So, verification by changing back is possible.
*/
"use strict";
const PROJECT_DIR = process.env['HOME'] + '/ShortSands/DBL/0othersources/2016-10-01_BibleLeague';
const SOURCE_DIR = PROJECT_DIR + '/BLI-DIS-ARB-B-USFM-161001';
const TARGET_DIR = PROJECT_DIR + '/GNG-FIX-ARB-USFM';
const VALID_DIR = PROJECT_DIR + '/GNG-TEST-ARB-USFM';
const fs = require('fs');

var convert = function(sourceDir, targetDir, fromText, toText) {
	var fromRegEx = new RegExp(fromText, 'gm');
	console.log('regex', fromRegEx);
	const files = fs.readdirSync(sourceDir);
	for(var i=0; i<files.length; i++) {
		var file = files[i];
		if (file.indexOf('.SFM') > -1) {
			var contents = fs.readFileSync(sourceDir + '/' + file, { encoding: 'utf-8'});
			var revised = contents.replace(fromRegEx, toText);
			fs.writeFileSync(targetDir + '/' + file, revised, { encoding: 'utf-8'});
		}
	}
}
var compare = function(sourceDir, validDir) {
	var script = [];
	script.push('#!/bin/sh');
	const files = fs.readdirSync(sourceDir);
	for(var i=0; i<files.length; i++) {
		var file = files[i];
		script.push('diff ' + sourceDir + '/' + file + ' ' + validDir + '/' + file);
	}
	fs.writeFileSync('ERVARBDiff.sh', script.join('\n'), { encoding: 'utf-8'});
}

convert(SOURCE_DIR, TARGET_DIR, '[\\][n][d][2]', 'bd');
convert(TARGET_DIR, VALID_DIR, '[\\][b][d]', 'nd2');
compare(SOURCE_DIR, VALID_DIR);