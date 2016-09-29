

var path = require('path');
var request = require('request');
var ApiBuilder = require('claudia-api-builder');
//var api = module.exports = new ApiBuilder('AWS_PROXY');
var api = new ApiBuilder('AWS_PROXY');
module.exports = api;
//var superb = require('superb');
var pageRewriter = require('./pageRewriter');
	
/**
 * This handler parses the href of a request, and makes an http GET request for the page.
 * It rewrites the page to change all href command to ones that will access the web through
 * the proxy.
 */
api.get('/web', function(event, context) {
	"use strict";
	console.log('start of get web');
	var options = {
	    url: event.queryString.url,
	    method: 'GET'
	};
	var ext = path.extname(options.url).toLowerCase();
	switch(ext) {
		case '.png':
		case '.jpg':
		case '.jpeg':
			options.encoding = null;
			break;
		default:
			options.encoding = 'utf8';
	}
	return new Promise(function(resolve, reject) {
		request(options, function (error, response, body) {
			if (!error && response.statusCode == 200) {
				if (options.encoding) {
					body = pageRewriter(body, options.url, '');/// path needs to be here
					resolve(new api.ApiResponse(body, {'Content-Type': 'text/html'}, 200));
				} else {
					resolve(new api.ApiResponse(body, {'Content-Type': 'image/png'}, 200));
				}
			} else {
				var text = '<html><body><h2>' + JSON.stringify(error) + '</h2></body></html>';
				resolve(new api.ApiResponse(text, {'Content-Type': 'text/html'}, 404));
			}
		});
	});
});
