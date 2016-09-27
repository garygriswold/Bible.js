
var PROXY = 'https://fgko66i9b3.execute-api.us-west-2.amazonaws.com/latest/web?url=';

var ApiBuilder = require('claudia-api-builder');
var api = module.exports = new ApiBuilder();
var superb = require('superb');
	
/**
 * This handler parses the href of a request, and makes an http GET request for the page.
 * It rewrites the page to change all href command to ones that will access the web through
 * the proxy.
 */
api.get('/web', function(event) {
	"use strict";
	var parser = require('url');
	var webURL = parser.parse(event.queryString.url);
	var options = {
	    hostname: webURL.hostname,
	    port: webURL.port || 80,
	    path: webURL.pathname,
	    method: 'GET'
	};
	return new Promise(function(resolve, reject) {
		var http = require('http');
	    var request = http.request(options, function(response) {
	        var body = [];
	        response.setEncoding('utf8');
	        response.on('data', function(chunk) {
		       body.push(chunk);
	        });
		    response.on('end', function() {
	            var webPage = body.join('');
	            var rewritten = webPage.replace(/href="(.*)"/g, 'href="' + PROXY + '$1' + '"');
	            resolve(rewritten);
	        });
	    });
	    request.on('error', function(error) {  
			errorResponse(error);
	    });
	    request.write(JSON.stringify(event));
	    request.end();
	
	    function errorResponse(error) {
	        console.log(JSON.stringify(error));
	        switch(error.code) {
	            case 'ENOTFOUND':
	                returnError(404, 'Server Not Found');
	                break;
	            default:
	                returnError(500, 'Unknown Error');      
	        }
	    }
	    function returnError(code, message) {
	        var text = '<html><body><h1>' + message + '</h1></body></html>';
	        reject(text);
	    }
	});
}, {error: {code: 404, contentType: 'text/html'}, success: {contentType: 'text/html'}});
