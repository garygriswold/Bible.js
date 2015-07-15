/**
* This is the Bible download server
* http://host/down/XXX - downloads version XXX
* http://host/lang/xx-XXX - downloads list of related versions for locale
* and possibly it will also handle student questions and answers
* http://host/ques/GUID post json - post newly asked question for answer
* http://host/answ/GUID - request answer to previously asked question
*/

function BibleServer(port, biblesPath, biblesSuffix) {
	this.port = port;
	this.biblesPath = biblesPath;
	this.biblesSuffix = biblesSuffix;
}
BibleServer.prototype.install = function() {
	var http = require('http');
	var url = require('url');
	var fs = require('fs');

	var that = this;
	http.createServer(function(request, response) {
		var requestURL = url.parse(request.url);
		if (requestURL) {
			console.log('request:', requestURL.pathname);
			var pathList = requestURL.pathname.split('/');
			if (pathList[1] === 'down') {

				var pathname = that.biblesPath + pathList[2] + that.biblesSuffix;
				fs.readFile(pathname, 'binary', function(err, file) {
					if (err) {
						console.log('Read file error', pathname, JSON.stringify(err));
						that.errorResponse(404, 'Version Not Found', response);
					} else {
						response.writeHead(200);
						response.end(file, 'binary');
					}
				});
			} else {
				that.errorResponse(400, 'Unknown Request', response);
			}
		} else {
			that.errorResponse(400, 'Invalid Request', response);
		}
	}).listen(this.port);
	console.log('server running on http://localhost:' + this.port + '/');
}
BibleServer.prototype.errorResponse = function(code, message, response) {
	console.log('Error', code, message);
	response.writeHead(code, { 'Content-Type': 'text/plain' });
	response.end(message + '\n');
};

var server = new BibleServer(8080, process.env.HOME + '/bibles/', '.sqlite');
server.install();


