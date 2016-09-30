/**
* This handler parses the href of a request, and makes an http GET request for the page.
* It rewrites the page to change all href command to ones that will access the web through
* the proxy.
*/

var ApiBuilder = require('claudia-api-builder');
var api = new ApiBuilder('AWS_PROXY');
module.exports = api;
var httpClient = require('./httpClient');
	
api.get('/web', function(event, context) {
	"use strict";
	console.log('start of get web', event.queryString.url);
	return new Promise(function(resolve, reject) {
		httpClient(event.queryString.url, function(status, body, headers) {
			console.log('got web', status, JSON.stringify(headers));
			resolve(new api.ApiResponse(body, headers, status));
		});
	});
});
