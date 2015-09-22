/**
* This class is handles registration, first login, and regular transaction authentication.
*/
"use strict";
function AuthController(database) {
	this.database = database;
	this.sqlite3 = require('sqlite3');
	this.CryptoJS = require('./lib/aes.js');
}
AuthController.prototype.auth = function(request, callback) {
	var that = this;
	console.log('INSIDE REQUEST', request.headers);
	var authorization = request.headers.authorization;
	console.log('auth', authorization);
	var authParts = (authorization) ? authorization.split(/\s+/) : null;
	console.log('parts', authParts);
	var datetime = request.headers.date;
	console.log('date', datetime);
	if (authorization && authParts.length === 3 && datetime) {
		var teacherId = authParts[1];
		var encrypted = authParts[2];
		console.log('teacher, encrypted', teacherId, encrypted);
		this.database.get('SELECT passPhrase FROM Teacher WHERE teacherId=?', teacherId, function(err, row) {
			console.log('RESULT', err, row);
			if (err) {
				callback(err, row);
			} else if (row === null) {
				authorizationError();
			} else {
				console.log('passphrase', row.passPhrase);
				var decrypted = that.CryptoJS.AES.decrypt(encrypted, row.passPhrase);
				var fullyDecrypted = decrypted.toString(CryptoJS.enc.Utf8);
				console.log('fully decrypted', fullyDecrypted);
				if (fullyDecrypted !== clearTextDatetime) {
					authorizationError();
				} else {
					callback();
				}
			}
		});
	} else {
		authorizationError();
	}
	
	function authorizationError() {
		var error = new Error('Unauthorized.');
		error.statusCode = 401;
		callback(error);
	}
};
AuthController.prototype.register = function(obj, callback) {
	console.log('REGISTER', obj);
	if (obj.name && obj.pseudonym) {
		obj.passPhrase = this.uniquePassPhrase(obj);
		this.database.insertTeacher(obj, function(err, results) {
			if (results) {
				results.passPhrase = obj.passPhrase;
			}
			callback(err, results);
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
	this.database.get('SELECT teacherId FROM Teacher WHERE passPhrase=?', passPhrase, function(err, row) {
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
AuthController.prototype.uniquePassPhrase = function(obj) {
	var passPhrase = generatePassPhrase(obj);
	this.database.get('SELECT count(*) as count FROM Teacher where passPhrase=?', passPhrase, function(err, row) {
		if (err) {
			callback(err, row);
		} else if (row.count > 0) {
			uniquePassPhrase(obj);
		} else {
			return(passPhrase);
		}
	});

	function generatePassPhrase(obj) {
		var that = this;
		this.database.get('SELECT versionId FROM Position WHERE teacherId=?', obj.teacherId, function(err, row) {
			if (err) {
				callback(err, row);
			} else {
				var bible = new that.sqlite3.Database(row.versionId + '.bible1');
				bible.get('SELECT count(*) as count FROM Concordance', function(err, row) {
					if (err) {
						callback(err, row);
					} else {
						var array = [];
						for (var i=0; i<5; i++) {
							array.push(Math.random() * row.count);
						}
						bible.all('SELECT word FROM concordance WHERE rowid IN (?,?,?,?,?)', array, function(err, results) {
							if (err) {
								callback(err, results);
							} else {
								for (var i=0; i<results.length; i++) {
									var row = results[i];
									var word = row.word.charAt(0).toUpperCase() + row.word.slice(1);
								}
							}
						});
						var passPhrase = generate([], bible, row.count, 0);
						callback(null, {passPhrase: passPhrase});
					}
				});
			}
		});
	}	
};




module.exports = AuthController;
