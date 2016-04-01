/**
* This class is handles registration, first login, and regular transaction authentication.
*
* Transactions that are restricted contain a Signature authorization header of the form:
* Authorization: Signature  teacherId  encryptedDateTime
* Where the datetime was encrypted using the passPhrase as a key.  These headers are checked
* by the auth method, which uses the teacherId to lookup the passPhrase to decrypt the
* third part of the signature, which is then checked against the Date header.  If the
* auth method does not approve the user, the server responds with a 401.
*
* When a user is registered they are given a passPhrase by some means that is deliberately
* outside the scope of the system.  In cases where confidentiality is of most concern, the
* passPhrase might be given to the user on a slip of paper.  The user enters this into the
* QAApp on first use, and it is transmitted to the server as a login transaction.  The passPhrase
* is encrypted using the Datetime as the key.  The server decrypts it, and looks it up to find
* the associated teacherId, which is transmitted back to the user.  The QAApp puts the teacherId
* and the passPhrase into localstorage where they can be used to send Signature authorization
* headers.
*
* In order for a person wishing to be a teacher to receive a teacherId and a passPhrase,
* they must be registered by someone who is registered as a principal or director.
* This authorizing person enters person's name and pseudonym (public name) into the
* QAApp, which sends it to the server.  The server generates a teacherId, and a passPhrase
* from the intended teacher.
*
* The following describes this process as a series of steps.
* 1) Principal or director registers a new teacher.
* 2) Server generates, a GUID to be a teacherId.
* 3) Server generates a Pass-Phrase as a concatenation of multiple words.
* 4) The Pass-Phrase and the GUID are both guaranteed to be unique.
* 5) Teacher name, GUID, and Pass-Phrase are all stored in the Teacher table.
* 6) The Pass-Phrase is manually, by email, or by text communicated to the user.
* 7) The first time the new user logs into the QAApp, they are asked for the Pass-Phrase.
* 8) When a correct Pass-Phrase is entered, the GUID is downloaded to the QAApp.
* 9) The QAApp stores the GUID and pass-phrase in local storage.
* 10) Each subsequent message to the server contain the GUID and an encrypted datetime
* 11) Authentication is done by decrypting the datetime and comparing it to datetime header.
*
*/
"use strict";
function AuthController(database) {
	this.database = database;
	this.sqlite3 = require('sqlite3');
	this.CryptoJS = require('./lib/aes.js');
	var fs = require('fs');
	this.biblePath = fs.realpathSync(__dirname + '/../../StaticRoot/book/');
}
AuthController.prototype.authenticate = function(request, callback) {
	var that = this;
	var authorization = request.headers.authorization;
	var authParts = (authorization) ? authorization.split(/\s+/) : null;
	var datetime = request.headers['x-time'];
	
	if (authorization && authParts.length === 3 && datetime) {
		var authId = authParts[1];
		var encrypted = authParts[2];
		this.database.db.get('SELECT passPhrase FROM Teacher WHERE teacherId=?', authId, function(err, row) {
			if (err) {
				callback(err);
			} else if (row === undefined) {
				authorizationError('Unknown TeacherId');
			} else {
				try {
					var decrypted = that.CryptoJS.AES.decrypt(encrypted, row.passPhrase);
					var fullyDecrypted = decrypted.toString(that.CryptoJS.enc.Latin1);
					if (fullyDecrypted !== datetime) {
						authorizationError('User Verification Failure');
					} else {
						request.headers.authId = authId;
						callback();
					}
				} catch(err) {
					authorizationError('Error While Decrypting User Signature');
				}
			}
		});
	} else {
		authorizationError('User Authorization Data Incomplete');
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
				callback(err)
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
	var authorization = request.headers.authorization;
	var authParts = (authorization) ? authorization.split(/\s+/) : null;
	var datetime = request.headers['x-time'];
	if (authorization && authParts.length === 2 && datetime) {
		var decrypted = this.CryptoJS.AES.decrypt(authParts[1], datetime);
		var passPhrase = decrypted.toString(this.CryptoJS.enc.Latin1);		
		this.database.db.get('SELECT teacherId FROM Teacher WHERE passPhrase=?', passPhrase, function(err, row) {
			if (err) {
				callback(err);
			} else if (row === undefined) {
				loginError('Unknown Pass Phrase');
			} else {
				callback(null, {teacherId: row.teacherId});
			}
		});
	} else {
		loginError('Login Data Incomplete');
	}
	
	function loginError(message) {
		var error = new Error(message);
		error.statusCode = 401;
		callback(error);
	}
};
AuthController.prototype.newPassPhrase = function(obj, callback) {
	var that = this;
	this.uniquePassPhrase(obj, function(err, passPhrase) {
		if (err) {
			callback(err);
		} else {
			that.database.executeSQL(['UPDATE Teacher SET passPhrase=? WHERE teacherId=?'], [[ passPhrase, obj.teacherId ]], 1, function(err, row) {
				if (row) {
					row.passPhrase = passPhrase;
				}
				callback(err, row);
			});
		}
	});
};
/**
* This method is used to authorize test methods that should never be run in production.
*/
AuthController.prototype.authorizeTester = function(authorizedId, callback) {
	if (authorizedId === 'GNG') {
		callback();
	} else {
		var error = new Error('You are not authorized to run this test routine.');
		error.statusCode = 403;
		callback(error);
	}
};
/**
* This auth function is used for /user update and /user delete.  It does not really check all necessary conditions, because it does not check 
* that principal/director has a common version with the teacher.  Doing this would require a join.
*/
AuthController.prototype.authorizeUser = function(authorizedId, callback) {
	this.authorize('SELECT count(*) as count FROM Position WHERE teacherId=? AND position IN ("principal", "director", "board")',
		[ authorizedId ], 'You are not authorized for this action.', callback);
};

AuthController.prototype.authorizePosition = function(authorizedId, position, versionId, callback) {
	if (position === 'board') {
		var error = new Error('You are not authorized for this action.');
		error.statusCode = 403;
		callback(error);
	} else {
		this.authorize('SELECT count(*) as count FROM Position WHERE teacherId=? AND (position IN("director", "board") OR (position="principal" AND versionId=?))',
			[ authorizedId, versionId ], 'You are not authorized for this action.', callback);
	}	
};

AuthController.prototype.authorizeVersion = function(authorizedId, versionId, callback) {
	this.authorize('SELECT count(*) as count FROM Position WHERE teacherId=? AND position IN ("teacher", "principal") AND versionId=?',
		[ authorizedId, versionId ], 'User is not authorized for this version.', callback);
};

AuthController.prototype.authorizeDiscourse = function(authorizedId, discourseId, callback) {
	this.authorize('SELECT count(*) as count FROM Discourse where teacherId=? AND discourseId=? AND status IN ("assigned", "answered")', 
		[ authorizedId, discourseId ], 'User is not assigned this question.', callback);
};

AuthController.prototype.authorize = function(statement, values, message, callback) {
	this.database.db.get(statement, values, function(err, row) {
		if (err) {
			callback(err);
		} else if (row.count === 0) {
			var error = new Error(message);
			error.statusCode = 403;
			callback(error);
		} else {
			callback();
		}		
	});
};
AuthController.prototype.uniquePassPhrase = function(obj, callback) {
	var that = this;
	var bible = new that.sqlite3.Database(this.biblePath + '/' + obj.versionId + '.db1');
	bible.get('SELECT count(*) as count FROM concordance', function(err, row) {
		if (err) {
			bible.close();
			callback(err, row);
		} else {
			var array = [];
			for (var i=0; i<3; i++) {
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
