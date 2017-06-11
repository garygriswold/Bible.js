/**
* This class processes Video Analytics and inserts and updates them into the VideoViews table.
*/

"use strict";
function InsertVideoViews(database) {
	this.database = database;
}

InsertVideoViews.prototype.insert = function(row, callback) {	
	console.log('VIDEO INSERT READ FILE', row);
	var statement = 'INSERT INTO VideoViews (' +
		' sessionId,' +
		' timeStarted,' +
		' mediaSource,' +
		' mediaId,' +
		' languageId,' +
		' silLang,' +
		' isStreaming,' + // Boolean 0 or 1
		' language,' +
		' country,' +
		' locale,' +
		' deviceType,' +
		' deviceFamily,' +
		' deviceName,' +
		' deviceOS,' +
		' osVersion,' +
		' appName,' +
		' appVersion,' +
		' mediaViewStartingPosition' +
		' ) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)';
	var record = [ row.sessionId, row.timeStarted, row.mediaSource, row.mediaId, row.languageId, row.silLang,
				row.isStreaming, row.language, row.country, row.locale, row.deviceType, row.deviceFamily, row.deviceName,
				row.deviceOS, row.osVersion, row.appName, row.appVersion, row.mediaViewStartingPosition ];
	this.database.execute(statement, [record], function() {
		callback();
	});
};

InsertVideoViews.prototype.update = function(row, callback) {	
	console.log('VIDEO UPDATE READ FILE', row);
	var statement = 'UPDATE VideoViews SET' +
		' timeCompleted = ?,' +
		' elapsedTime = ?,' +
		' mediaTimeViewInSeconds = ?,' +
		' mediaViewCompleted = ?' + // Boolean 0 or 1
		' WHERE sessionId = ? AND timeStarted = ?';
	var record = [ row.timeCompleted, row.elapsedTime, row.mediaTimeViewInSeconds, row.mediaViewCompleted, 
					row.sessionId, row.timeStarted ];
	this.database.execute(statement, [record], function() {
		callback();
	});
};


module.exports = InsertVideoViews;