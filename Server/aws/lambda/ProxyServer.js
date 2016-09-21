'use strict';

console.log('Loading Proxy function');
const http = require('http');
const url = require('url');
const PROXY = 'https://detq1j96hc.execute-api.us-west-2.amazonaws.com/prod/ShortSandsProxy?href=';
/**
 * This handler parses the href of a request, and makes an http GET request for the page.
 * It rewrites the page to change all href command to ones that will access the web through
 * the proxy.
 */
exports.handler = (event, context) => {
    console.log('Received event:', JSON.stringify(event, null, 2));
    const webURL = url.parse(event.url);
    const options = {
        hostname: webURL.hostname,
        port: webURL.port || 80,
        path: webURL.pathname,
        method: 'GET'
    };
    const request = http.request(options, function(response) {
        let body = [];
        console.log('Status:', response.statusCode);
        console.log('Headers:', JSON.stringify(response.headers));
        response.setEncoding('utf8');
        response.on('data', function(chunk) {
	       body.push(chunk);
        });
	    response.on('end', function() {
            console.log('Successfully processed HTTPS response');
            const webPage = body.join('');
            const rewritten = webPage.replace(/href="(.*)"/g, 'href="' + PROXY + '$1' + '"');
            context.succeed(rewritten);
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
        context.succeed(text);
    }
};
