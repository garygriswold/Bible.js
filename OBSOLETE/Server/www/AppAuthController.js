/**
* This class is handles authentication that a request came from a copy of an App, which this
* server supports.
*
* Transactions must contain a Signature authorization header of the form:
* Authorization: Signature  appId  appVersion  encryptedDateTime
* Where the datetime was encrypted using the passPhrase as a key.  These headers are checked
* by the authenticate method, which uses the appId and appVersion to lookup the passPhrase 
* and to decrypt the fourth part of the signature, which is then checked against the X-Time header.  
* If the auth method does not approve the user, the server responds with a 401.
*
*/
"use strict";
function AppAuthController() {
	this.sqlite3 = require('sqlite3');
	this.db = new this.sqlite3.Database('Credentials.db');
	this.CryptoJS = require('./lib/aes.js');
}
AppAuthController.prototype.authenticate = function(request, callback) {
	var that = this;
	var authorization = request.headers.authorization;
	var authParts = (authorization) ? authorization.split(/\s+/) : null;
	var datetime = request.headers['x-time'];
	
	if (authorization && authParts.length === 4 && datetime) {
		var appId = authParts[1];
		var appVersion = authParts[2];
		var encrypted = authParts[3];
		this.db.get('SELECT key FROM credentials WHERE id=? AND version=?', appId, appVersion, function(err, row) {
			if (err) {
				callback(err);
			} else if (row === undefined) {
				authorizationError('Unknown App Version');
			} else {
				try {
					var decrypted = that.CryptoJS.AES.decrypt(encrypted, row.key);
					var fullyDecrypted = decrypted.toString(that.CryptoJS.enc.Latin1);
					if (fullyDecrypted !== datetime) {
						authorizationError('App Verification Failure');
					} else {
						callback();
					}
				} catch(err) {
					authorizationError('Error While Decrypting App Signature');
				}
			}
		});
	} else {
		authorizationError('App Authorization Data Incomplete');
	}
	
	function authorizationError(message) {
		var error = new Error(message);
		error.statusCode = 401;
		callback(error);
	}
};

module.exports = AppAuthController;
