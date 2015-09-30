/**
* This class is the client side of authorization.  It needs to handle a number of key functions.
* 1) It is able store and retreive credentials from the localstorage.
* 2) When there are no stored credentials, a pass phrase must be entered
* 3) It sends a user entered pass phrase to the server, where it is looked up,
* and the corresponding GUID are returned.
* 4) The GUID and pass phrase are stored in the localstorage.
* 5) Normal processing when these credentials do exists, are to
* 6) create an Authorization header of type signature with the
* 7) Date value encrypted by the pass phrase. 
*/
"use strict";
function AuthClient(httpClient) {
	this.httpClient = httpClient;
	Object.seal(this);
}
AuthClient.prototype.login = function(passPhrase, callback) {
	var that = this;
	this.httpClient.login(passPhrase, function(status, result) {
		if (status < 200 || status > 201) {
			callback(result);
		} else if (result === null || result.teacherId === null) {
			var error = new Error('Login attempt failed ' + status + ' ' + JSON.stringify(result));
			console.error(error);
			callback(error);
		} else {
			that.setCredentials(result.teacherId, passPhrase);
			callback();
		}
	});
};
AuthClient.prototype.signLogin = function(request, passPhrase) {
	//var datetime = request.getRequestHeader('Date');
	var datetime = new Date().toString();
	console.log('request date', datetime);
	var encrypted = CryptoJS.AES.encrypt(passPhrase, datetime);
	request.setRequestHeader('Authorization', 'Login  ' + encrypted);
};
//AuthClient.prototype.loginResponse = function(result) {
//	if (result && result.teacherId) {
//		this.setCredentials(result.teacherId, this.passPhrase);
//	}
//};
AuthClient.prototype.signRequest = function(request) {
	var credential = this.getCredentials();
		if (credential) {
		var datetime = request.getRequestHeader('Date');
		var encrypted = CryptoJS.AES.encrypt(datetime, credential.passPhrase);
		request.setRequestHeader('Authorization', 'Signature  ' + credential.user + '  ' + encrypted);
	}
};
AuthClient.prototype.hasCredentials = function() {
	return(localStorage.getItem('user') !== null);
}
AuthClient.prototype.getCredentials = function() {
	return(localStorage.getItem('user'));
};
AuthClient.prototype.setCredentials = function(guid, passPhrase) {
	localStorage.setItem('user', {user:guid, passPhrase:passPhrase});
};

