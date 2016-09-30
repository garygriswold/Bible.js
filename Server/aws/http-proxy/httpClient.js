/**
 * This object makes an http GET request for any web page element.
 * It follows redirects, and returns the correct content-type headers
 */
"use strict";
var path = require('path');
var request = require('request');
var pageRewriter = require('./pageRewriter');

var httpClient = function(url, callback) { // callback(status, body, headers);
	var options = getOptions(url);
	console.log('GET', JSON.stringify(options));
	request(options, function(error, response, body) {
		if (!error && response.statusCode >= 200 && response.statusCode <= 299) {
			var headers = forwardHeaders(response.headers);
			if (headers['content-type'].indexOf('html') > 0) {
				body = pageRewriter(body, options.url, '');/// path needs to be here
			}
			callback(response.statusCode, body, headers);
		} else {
			var status = (response) ? response.statusCode : null;
			var text = '<html><body><h1>Status: ' + status + '</h1><h2>Error: ' + JSON.stringify(error) + '</h2></body></html>';
			callback(404, text, {'content-type': 'text/html'});
		}
	});
	
	function getOptions(url) {
		var options = {
		    url: url,
		    method: 'GET'
		};
		var ext = path.extname(url).toLowerCase();
		switch(ext) {
			case '.png':
			case '.jpg':
			case '.jpeg':
			case '.gif':
				options.encoding = null;
				break;
			default:
				options.encoding = 'utf8';
		}
		return(options);		
	}
	
	function forwardHeaders(origHeaders) {
		var types = ['content-type', 'content-length', 'cache-control', 'pragma', 'expires'];
		var headers = {};
		for (var i=0; i<types.length; i++) {
			var type = types[i];
			if (origHeaders[type]) {
				headers[type] = origHeaders[type];
			}
		}
		return(headers);
	}
}

module.exports = httpClient;

/**
Unit Test
*/
/*
//var url = 'http://shortsands.com';
var url = 'http://shortsands.com/wp-content/uploads/2016/04/shortSandsLogo04.png';
var fs = require('fs');
httpClient(url, function(status, body, headers) {
	fs.writeFile('testFileOut.png', body, function(error) {
		if (error) {
			console.log('File Write Error ', error);
		}
	});
	console.log(status, JSON.stringify(headers));	
});
*/
