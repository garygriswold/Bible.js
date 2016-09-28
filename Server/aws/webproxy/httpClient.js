/**
* This class is passed a web URL and returns the content of the page or object
* It follows redirects, and encodes content according to type.
*/
var http = require('http');
var pageRewriter = require('./pageRewriter');

var httpClient = function(url) {
	var parser = require('url');
	var webURL = parser.parse(url);
	var options = {
	    hostname: webURL.hostname,
	    port: webURL.port || 80,
	    path: webURL.pathname,
	    method: 'GET'
	};
	return new Promise(function(resolve, reject) {
		
	    var request = http.request(options, function(response) {
	        var body = [];
	        if (webURL.pathname.indexOf('.png') < 0) {
	        	response.setEncoding('UTF-8');
	        }
	        response.on('data', function(chunk) {
		       body.push(chunk);
	        });
		    response.on('end', function() {
	            var webPage = body.join('');
	            var rewritten = pageRewriter(webPage, webURL.protocol + '//' + webURL.hostname, webURL.path);
	            resolve(rewritten);
	        });
	    });
	    request.on('error', function(error) {  
			errorResponse(error);
	    });
	    //request.write(JSON.stringify(event));
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
}

/**
* unit test of httpClient
*/
var page = httpClient('http://www.google.com');
console.log(page);