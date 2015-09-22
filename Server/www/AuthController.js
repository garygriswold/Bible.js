/**
* This class is handles registration, first login, and regular transaction authentication.
*/
"use strict";
function AuthController(database) {
	this.database = database;
	this.sqlite3 = require('sqlite3');
	this.CryptoJS = require('./lib/aes.js');
	var fs = require('fs');
	this.biblePath = fs.realpathSync(__dirname + '/../../StaticRoot/bible/');
}
AuthController.prototype.auth = function(request, callback) {
	var that = this;
	var authorization = request.headers.authorization;
	var authParts = (authorization) ? authorization.split(/\s+/) : null;
	var datetime = request.headers.date;
	
	if (authorization && authParts.length === 3 && datetime) {
		var authId = authParts[1];
		var encrypted = authParts[2];
		this.database.db.get('SELECT passPhrase FROM Teacher WHERE teacherId=?', authId, function(err, row) {
			if (err) {
				callback(err);
			} else if (row === undefined) {
				console.log('UNKNOWN TEACHERID', authId);
				authorizationError('Unknown TeacherId');
			} else {
				try {
					var decrypted = that.CryptoJS.AES.decrypt(encrypted, row.passPhrase);
					var fullyDecrypted = decrypted.toString(that.CryptoJS.enc.Latin1);
					if (fullyDecrypted !== datetime) {
						authorizationError('Verification Failure');
					} else {
						request.headers.authId = authId;
						callback();
					}
				} catch(err) {
					authorizationError('Error While Decrypting');
				}
			}
		});
	} else {
		authorizationError('Authorization Data Incomplete');
	}
	
	function authorizationError(message) {
		var error = new Error(message);
		error.statusCode = 401;
		callback(error);
	}
};
AuthController.prototype.register = function(obj, callback) {
	var that = this;
	if (obj.fullname && obj.pseudonym) {
		this.uniquePassPhrase(obj, function(err, passPhrase) {
			if (err) {
				callback(err, passPhrase)
			} else {
				obj.passPhrase = passPhrase;
				that.database.insertTeacher(obj, function(err, results) {
					if (results) {
						results.passPhrase = obj.passPhrase;
					}
					callback(err, results);
				});
			}
		});
	} else {
		var err = new Error('Register with fullname and pseudonym');
		err.statusCode = 400;
		callback(err);
	}
};
AuthController.prototype.login = function(request, callback) {
	console.log('AUTHORIZATION', request.authorization);
	var datetime = request.getHeader('Date');
	var encryptedPassPhrase = request.authorization.basic.password;
	var passPhrase = this.CryptoJS.AES.decrypt(encryptedDatetime, key);
	this.database.db.get('SELECT teacherId FROM Teacher WHERE passPhrase=?', passPhrase, function(err, row) {
		if (err && row === null) {
			var err = new Error('Unknown passPhrase');
			err.statusCode = 401;
		}
		callback(err, row);
	});
};
AuthController.prototype.newPassPhrase = function(obj, callback) {
	var passPhrase = this.uniquePassPhrase(obj);
	this.database.executeSQL(['UPDATE Teacher SET passPhrase=? WHERE teacherId=?'], [[ passPhrase, obj.teacherId ]], 1, function(err, row) {
		if (row) {
			row.passPhrase = passPhrase;
		}
		callback(err, row);
	});
};
AuthController.prototype.uniquePassPhrase = function(obj, callback) {
	var that = this;
	var bible = new that.sqlite3.Database(this.biblePath + '/' + obj.versionId + '.bible1');
	bible.get('SELECT count(*) as count FROM concordance', function(err, row) {
		if (err) {
			bible.close();
			callback(err, row);
		} else {
			var array = [];
			for (var i=0; i<5; i++) {
				array.push(Math.round(Math.random() * row.count));
			}
			bible.all('SELECT word FROM concordance WHERE rowid IN (?,?,?,?,?)', array, function(err, results) {
				if (err) {
					bible.close();
					callback(err, results);
				} else {
					array = [];
					for (var i=0; i<results.length; i++) {
						var row = results[i];
						var word = row.word.charAt(0).toUpperCase() + row.word.slice(1);
						array.push(word);
					}
					var passPhrase = array.join('');
					that.database.db.get('SELECT count(*) as count FROM Teacher where passPhrase=?', passPhrase, function(err, row) {
						bible.close();
						if (err) {
							callback(err, row);
						} else if (row.count > 0) {
							that.uniquePassPhrase(obj, callback);
						} else {
							callback(null, passPhrase);
						}
					});
				}
			});
		}
	});	
};


module.exports = AuthController;
