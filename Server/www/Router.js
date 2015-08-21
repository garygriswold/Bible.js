/**
* This class is the front-end of the server, and performs all routing
* to individual controllers.
*/
var restify = require('restify');
var serverOptions = {};
var server = restify.createServer(serverOptions);
server.pre(restify.pre.userAgentConnection()); // if UA is curl, close connection and remove Content-Length header.

server.use(restify.bodyParser({
	maxBodySize: 10000,
	mapParams: true
}));

server.get('/version/:versionId', function(request, response, next) {
	console.log('Download version transaction ', request.params.versionId);
	response.send('Download Version TBD = ' + request.params.versionId);
	return(next());
});

server.get('/locale/:localeId', function(request, response, next) {
	console.log('Download Ethnologe info ', request.params.localeId);
	response.send('Download Ethnologe info = ' + request.params.localeId);
	return(next());	
});

server.post('/question', function(request, response, next) {
	console.log('POST question ' + request.params.question, request.params.hello);
	response.send('POST Question ' + request.params.question, request.params.hello);
	return(next());	
});

server.get('/:name', function(request, response, next) {
	response.send('hello world ' + request.params.name);
	return(next());
});

server.listen(8080, function() {
	console.log('listening on 8080');
});