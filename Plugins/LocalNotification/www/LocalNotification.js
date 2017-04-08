"use strict";
	
exports.requestPermission = function(callback) {
	console.log('INSIDE REQUEST PERM');
	cordova.exec(callback, function(error) {
		console.log('ERROR INSIDE www/LocalNotification.requestPermission', JSON.stringify(error));
	}, "LocalNotification", "requestPermission", []);
};

exports.schedule = function(id, title, body, when, data, callback) {
	cordova.exec(function(success) {
		callback(null);
	}, callback, "LocalNotification", "schedule", [id, title, body, when.getTime(), data]);
};

exports.getScheduledIds = function(callback) {
	cordova.exec(callback, function(error) {
		console.log('ERROR INSIDE www/LocalNotification.getScheduledIds', JSON.stringify(error));	
	}, "LocalNotification", "getScheduledIds", []);
};

exports.getTriggeredIds = function(callback) {
	cordova.exec(callback, function(error) {
		console.log('ERROR INSIDE www/LocalNotification.getTriggeredIds', JSON.stringify(error));
	}, "LocalNotification", "getTriggeredIds", []);
};

exports.getScheduledById = function(id, callback) {
	cordova.exec(callback, function(error) {
		console.log('ERROR INSIDE www/LocalNotification.getScheduledById', JSON.stringify(error));
	}, "LocalNotification", "getScheduledById", [id]);
};

exports.getTriggeredById = function(id, callback) {
	cordova.exec(callback, function(error) {
		console.log('ERROR INSIDE www/LocalNotification.getTriggeredById', JSON.stringify(error));
	}, "LocalNotification", "getTriggeredById", [id]);
};

exports.clearAllScheduled = function(callback) {
	cordova.exec(callback, function(error) {
		console.log('ERROR INSIDE www/LocalNotification.clearAllScheduled', JSON.stringify(error));
	}, "LocalNotification", "clearAllScheduled", []);
};

exports.clearAllTriggered = function(callback) {
	cordova.exec(callback, function(error) {
		console.log('ERROR INSIDE www/LocalNotification.clearAllTriggered', JSON.stringify(error));
	}, "LocalNotification", "clearAllTriggered", []);
};