/**
* This class is the front-end of the server, and performs all routing
* to individual controllers.
*/
"use strict";
var EthnologyController = require('./EthnologyController');
var ethnologyController = new EthnologyController();

var restify = require('restify');
var server = restify.createServer({
	name: 'BibleJS'
});
server.pre(restify.pre.userAgentConnection()); // if UA is curl, close connection.

server.use(restify.bodyParser({
	maxBodySize: 10000,
	mapParams: true
}));

server.get(/\/bible\/?.*/, restify.serveStatic({
	directory: '../../StaticRoot'
}));

server.put('/user', function registerTeacher(request, response, next) {
	console.log('Register a new user', request.params.username);
	response.send(200, 'Register a new user ' + request.params.username);
	// Uses database transaction insertUser
	return(next());
});

server.post('/user', function updateTeacher(request, response, next) {
	console.log('Update a user', request.params.username);
	response.send(200, 'Update new user ' + request.params.username);
	// Uses database transaction updateUser
	return(next());
});

server.del('/user', function deleteTeacher(request, response, next) {
	console.log('Delete user', request.params.username);
	response.send(200, 'Delete user ' + request.params.username);
	// Uses database transaction deleteUser
	return(next());
});

server.put('/position', function insertPosition(request, response, next) {
	console.log('Give user a new privilege', request.params.username);
	response.send(200, 'Register a new user ' + request.params.username);
	// Uses database transaction insertPosition
	return(next());
});

server.del('/position', function deletePosition(request, response, next) {
	console.log('Remove a privilege', request.params.username);
	response.send(200, 'Remove a privilege ' + request.params.username);
	// Uses database transaction insertPosition
	return(next());
});

server.get('/versions/:locale', function getVersions(request, response, next) {
	console.log('Download Ethnologe info ', request.params.locale);
	var result = ethnologyController.availVersions(request.params.locale);
	response.send(200, JSON.stringify(result));
	return(next());	
});

server.put('/question', function insertQuestion(request, response, next) {
	console.log('Insert question ' + request.params.question);
	response.send(200, 'Insert Question ' + request.params.question + ' ' + request.params.hello);
	return(next());	
});

server.post('/question', function updateQuestion(request, response, next) {
	console.log('POST question ' + request.params.question);
	response.send(200, 'POST Question ' + request.params.question + ' ' + request.params.hello);
	return(next());	
});

server.del('/question', function deleteQuestion(request, response, next) {
	console.log('Delete question ' + request.params.question);
	response.send(200, 'Delete Question ' + request.params.question + ' ' + request.params.hello);
	return(next());	
});

server.get('/open/:versionId', function openCount(request, response, next) {
	console.log('Open Question Status Message ', request.params.versionId);
	response.send(200, 'Open Question Status', request.params.versionId);
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

server.put('/answer', function insertAnswer(request, response, next) {
	console.log('Send response ', request.params.message);
	response.send(200, 'Send response ' + request.params.message);
	return(next());
});

server.post('/answer', function updateAnswer(request, response, next) {
	console.log('Update response ', request.params.message);
	response.send(200, 'Update response ' + request.params.message);
	return(next());
});

server.del('/answer', function deleteAnswer(request, response, next) {
	console.log('Delete response ', request.params.message);
	response.send(200, 'Delete response ' + request.params.message);
	return(next());
});

server.get('/answer/:discourseId', function getAnswers(request, response, next) {
	console.log('Get responses ', request.params.message);
	response.send(200, 'Get responses ' + request.params.message);
	return(next());
});

server.get('/draft/:draftId', function getDraft(request, response, next) {
	console.log('Get Draft ' + request.params.draftId);
	response.send(200, 'Get Draft ' + request.params.draftId);
	return(next());
});

server.post('/draft', function saveDraft(request, response, next) {
	console.log('Save Draft ' + request.params.message);
	response.send(200, 'Save Draft ' + request.params.message);
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

