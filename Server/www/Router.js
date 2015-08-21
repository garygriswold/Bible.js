/**
* This class is the front-end of the server, and performs all routing
* to individual controllers.
*/
var restify = require('restify');
var server = restify.createServer({
	name: 'BibleJS'
});
server.pre(restify.pre.userAgentConnection()); // if UA is curl, close connection.

server.use(restify.bodyParser({
	maxBodySize: 10000,
	mapParams: true
}));

server.post('/user', function registerUser(request, response, next) {
	console.log('Register a new user', request.params.username);
	response.send(200, 'Register a new user ' + request.params.username);
	return(next());
});

server.get('/version/:version', function downloadVersion(request, response, next) {
	console.log('Download version transaction ', request.params.version);
	response.send(200, 'Download Version TBD = ' + request.params.version);
	return(next());
});

server.get('/locale/:locale', function getVersions(request, response, next) {
	console.log('Download Ethnologe info ', request.params.locale);
	response.send(200, 'Download Ethnologe info = ' + request.params.locale);
	return(next());	
});

server.post('/question', function updateQuestion(request, response, next) {
	console.log('POST question ' + request.params.question);
	response.send(200, 'POST Question ' + request.params.question + ' ' + request.params.hello);
	return(next());	
});

server.get('/assign/:version', function assignQuestion(request, response, next) {
	console.log('Assign Question ', request.params.version);
	response.send(200, 'Assign Question ' + request.params.version);
	return(next());
});

server.get('/return/:questionId', function returnQuestion(request, response, next) {
	console.log('Return question ', request.params.questionId);
	response.send(200, 'Return question ' + request.params.questionId);
	return(next());
});

server.post('/send', function sendQuestion(request, response, next) {
	console.log('Send response ', request.params.message);
	response.send(200, 'Send response ' + request.params.message);
	return(next());
});

server.post('/draft', function saveDraft(request, response, next) {
	console.log('Save Draft ' + request.params.message);
	response.send(200, 'Save Draft ' + request.params.message);
	return(next());
});

server.get('/draft/:draftId', function getDraft(request, response, next) {
	console.log('Get Draft ' + request.params.draftId);
	response.send(200, 'Get Draft ' + request.params.draftId);
	return(next());
});

server.del('/draft/:draftId', function deleteDraft(request, response, next) {
	console.log('Delete Draft ' + request.params.draftId);
	response.send(200, 'Delete Draft ' + request.params.draftId);
	return(next());
});

server.get(/^.*$/, function getCatchAll(request, response, next) {
	return(invalidRequest(request, response, next));
});
server.put(/^.*$/, function getCatchAll(request, response, next) {
	return(invalidRequest(request, response, next));
});
server.post(/^.*$/, function getCatchAll(request, response, next) {
	return(invalidRequest(request, response, next));
});
server.del(/^.*$/, function getCatchAll(request, response, next) {
	return(invalidRequest(request, response, next));
});
server.head(/^.*$/, function getCatchAll(request, response, next) {
	return(invalidRequest(request, response, next));
});


server.listen(8080, function() {
	console.log('listening on 8080');
});

function invalidRequest(request, response, next) {
	console.log('No Valid Route', request.url);
	response.send(404, 'No Valid Route ' + request.url);
	return(next());
}

