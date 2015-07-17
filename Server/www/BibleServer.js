"use strict";
/**
* This is the Bible download server
* http://host/down/XXX - downloads version XXX
* http://host/lang/xx-XXX - downloads list of related versions for locale
* and possibly it will also handle student questions and answers
* http://host/ques/GUID post json - post newly asked question for answer
* http://host/answ/GUID - request answer to previously asked question
*/
function BibleServer(port, biblesPath) {
	this.port = port;
	this.biblesPath = biblesPath;
}
BibleServer.prototype.install = function() {
	var http = require('http');
	var url = require('url');
	var fs = require('fs');

	var that = this;
	http.createServer(function(request, response) {
		that.serverLog('Request', null, request.url);
		var requestURL = url.parse(request.url);
		if (requestURL) {
			var pathList = requestURL.pathname.split('/');
			if (pathList[1] === 'down') {
				var pathname = that.biblesPath + pathList[2];
				fs.readFile(pathname, 'binary', function(err, file) {
					if (err) {
						that.errorResponse(response, 404, 'Version Not Found', JSON.stringify(err));
					} else {
						response.writeHead(200);
						response.end(file, 'binary');
						that.serverLog('Success', 200, 'Success')
					}
				});
			} else {
				that.errorResponse(response, 400, 'Unknown Request');
			}
		} else {
			that.errorResponse(response, 400, 'Invalid Request');
		}
	}).listen(this.port);
	this.serverLog('_Start_', null, 'Bible Server listening on ' + this.port);
}
BibleServer.prototype.errorResponse = function(response, respCode, respMessage, errMessage) {
	this.serverLog('*Error*', respCode, respMessage, errMessage);
	response.writeHead(respCode, { 'Content-Type': 'text/plain' });
	response.end(respMessage + '\n');
};
BibleServer.prototype.serverLog = function(action, respCode, respMessage, errMessage) {
	console.log(new Date().toISOString(), action, respCode, respMessage, ((errMessage) ? errMessage : ''));
};

var server = new BibleServer(8080, process.env.HOME + '/bibles/');
server.install();


