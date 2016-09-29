/**
* This class is passed a web URL and returns the content of the page or object
* It follows redirects, and encodes content according to type.
*/
"use strict";
var http = require('http');
var pageRewriter = require('./pageRewriter');

var httpClient = function(url, callback) {
	var parser = require('url');
	var webURL = parser.parse(url);
	var options = {
	    hostname: webURL.hostname,
	    port: webURL.port || 80,
	    path: webURL.pathname,
	    method: 'GET'
	};
    var request = http.request(options, function(response) {
        var body = [];
        
        //response.setEncoding('binary');
        //if (webURL.pathname.indexOf('.png') < 0) {
        response.setEncoding('utf8');
        //}
        response.on('data', function(chunk) {
	       body.push(chunk);
        });
	    response.on('end', function() {
		    //var binary = Buffer.concat(body);
		    //callback(200, binary);
		    //resolve(binary);
		    callback(200, body.join(''));
		    //resolve(body);
            //var webPage = body.join('');
            //var rewritten = pageRewriter(webPage, webURL.protocol + '//' + webURL.hostname, webURL.path);
            //resolve(rewritten);
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
        //reject(text);
        callback(code, text);
    }
	//});
}

/**
* unit test of httpClient
*/
var fs = require('fs');
var page = 'http://www.google.com';
//var page = 'http://www.google.com/images/nav_logo242.png';
httpClient(page, function(code, body) {
	console.log('code', code);
	fs.writeFile('testPageOut.html', body, function(error) {
		console.log('file written', error);
	});	
});

//for (var prop in page) {console.log(prop, page[prop]);}
//fs.writeFile('testPageOut.png', page, {encoding:'binary'}, function(error) {

//console.log(page);