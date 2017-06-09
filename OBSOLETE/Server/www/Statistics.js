/**
* This class stores statistics into a statistics database 
*/
"use strict";
function Statistics() {
	this.log = require('./Logger');
	this.sqlite3 = require('sqlite3');
	this.db = new this.sqlite3.Database(DATABASE_ROOT + 'Statistics.db');
	this.createDownloads();
	Object.seal(this);
}
/**
* This method should be public in case
*/
Statistics.prototype.createDownloads = function() {
	var that = this;
	var createSQL = 'create table if not exists downloads(' +
		' datetime varchar(20) not null,' +
		' preferredLocale varchar(10) null,' +
		' locale varchar(10) null,' +
		' acceptLang varchar(20) null,' +
		' fromVersion varchar(20) null,' +
		' version varchar(20) not null)';
	this.db.run(createSQL, function(err) {
		if (err) {
			that.log.error(err, 'Statistics.createDownloads');
		}
	});
};
Statistics.prototype.insertDownload = function(request) {
	var that = this;
	var xLocale = request.headers['x-locale'];
	var parts = (xLocale) ? xLocale.split(',') : [];
	var preferredLocale = (parts.length > 0) ? parts[0] : null;
	var locale = (parts.length > 1) ? parts[1] : null;
	var acceptLang = request.headers['accept-language'];
	var fromVersion = request.headers['x-referer-version'];
	var path = request.getPath();
	var slash = path.lastIndexOf('/');
	var filename = (slash > -1) ? path.substr(slash + 1) : path;
	var version = (filename) ? filename.replace('.zip', '') : null;
	var datetime = new Date().toISOString();
	var insertSQL = 'insert into downloads(datetime, preferredLocale, locale, acceptLang, fromVersion, version) values (?,?,?,?,?,?)';
	this.db.run(insertSQL, datetime, preferredLocale, locale, acceptLang, fromVersion, version, function(err) {
		if (err) {
			that.log.error(err, 'Statistics.insertDownload');
		}
	});
};

module.exports = Statistics;