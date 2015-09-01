/**
* This class is the front-end of the server, and performs all routing
* to individual controllers.
*/
"use strict";
var EthnologyController = require('./EthnologyController');
var ethnologyController = new EthnologyController();

var DatabaseAdapter = require('./DatabaseAdapter');
var database = new DatabaseAdapter({filename: './TestDatabase.db', verbose: true}) 

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

server.get('/versions/:locale', function getVersions(request, response, next) {
	console.log('Download Ethnologe info ', request.params.locale);
	var result = ethnologyController.availVersions(request.params.locale);
	response.send(200, result);
	return(next());	
});

server.put('/user', function registerTeacher(request, response, next) {
	console.log('Register a new user', request.params);
	// Need to generate signature and add to request.params
	database.insertTeacher(request.params, function(err, results) {
		if (err) {
			response.send(409, err);
		} else {
			response.send(201, results);	
		}
		return(next());
	});
});

server.post('/user', function updateTeacher(request, response, next) {
	console.log('Update a user', request.params);
	database.updateTeacher(request.params, function(err, results) {
		if (err) {
			response.send(404, err);
		} else {
			response.send(200, results);
		}
		return(next());
	});
});

server.del('/user/:teacherId', function deleteTeacher(request, response, next) {
	console.log('Delete user', request.params);
	database.deleteTeacher(request.params, function(err, results) {
		if (err) {
			response.send(404, err); // could this also be a conflict error 409
		} else {
			response.send(200, results);
		}
		return(next());
	});
});

server.put('/position', function insertPosition(request, response, next) {
	console.log('Give user a new privilege', request.params);
	database.insertPosition(request.params, function(err, results) {
		if (err) {
			response.send(409, err); // not sure about status code
		} else {
			response.send(201, results);
		}
		return(next());
	});
});

server.post('/position', function updatePosition(request, response, next) {
	console.log('Give user a new privilege', request.params);
	database.updatePosition(request.params, function(err, results) {
		if (err) {
			response.send(409, err); // not sure about status code
		} else {
			response.send(200, results);
		}
		return(next());
	});
});

server.del('/position', function deletePosition(request, response, next) {
	console.log('Remove a privilege', request.params);
	database.deletePosition(request.params, function(err, results) {
		if (err) {
			response.send(404, err);
		} else {
			response.send(200, results);
		}
		return(next());
	});
});

server.put('/question', function insertQuestion(request, response, next) {
	console.log('Insert question ' + request.params);
	database.insertQuestion(request.params, function(err, results) {
		if (err) {
			response.send(409, err);
		} else {
			response.send(201, results);
		}
		return(next());
	});
});

server.post('/question', function updateQuestion(request, response, next) {
	console.log('POST question ' + request.params.question);
	database.updateQuestion(request.params, function(err, results) {
		if (err) {
			response.send(404, err);
		} else {
			response.send(200, results);
		}
		return(next());
	});
});

server.del('/question', function deleteQuestion(request, response, next) {
	console.log('Delete question ' + request.params.question);
	database.deleteQuestion(request.params, function(err, results) {
		if (err) {
			response.send(404, err);
		} else {
			response.send(200, results);
		}
		return(next());
	});
});

server.get('/open/:versionId', function openQuestionCount(request, response, next) {
	console.log('Open Question Status Message ', request.params.versionId);
	database.openQuestionCount(request.params, function(err, results) {
		if (err) {
			response.send(500, err);
		} else {
			response.send(200, results);
		}
		return(next());
	});
});

server.get('/assign/:versionId/:teacherId', function assignQuestion(request, response, next) {
	console.log('Assign Question ', request.params.version);
	database.assignQuestion(request.params, function(err, results) {
		if (err) {
			response.send(404, err);
		} else {
			response.send(200, results);
		}
		return(next());
	})
});

server.get('/return/:discourseId', function returnQuestion(request, response, next) {
	console.log('Return question ', request.params.discourseId);
	database.returnQuestion(request.params, function(err, results) {
		if (err) {
			response.send(404, err);
		} else {
			response.send(200, results);
		}
		return(next());
	});
});

server.put('/answer', function insertAnswer(request, response, next) {
	console.log('Send response ', request.params);
	database.insertAnswer(request.params, function(err, results) {
		if (err) {
			response.send(409, err);
		} else {
			response.send(201, results);
		}
		return(next());
	});
});

server.post('/answer', function updateAnswer(request, response, next) {
	console.log('Update response ', request.params);
	database.updateAnswer(request.params, function(err, results) {
		if (err) {
			response.send(404, err);
		} else {
			response.send(200, results);
		}
		return(next());
	});
});

server.del('/answer', function deleteAnswer(request, response, next) {
	console.log('Delete response ', request.params);
	database.deleteAnswer(request.params, function(err, results) {
		if (err) {
			response.send(404, err);
		} else {
			response.send(200, results);
		}
		return(next());
	});
});

server.get('/answer/:discourseId', function getAnswers(request, response, next) {
	console.log('Get responses ', request.params);
	database.selectAnswer(request.params, function(err, results) {
		if (err) {
			response.send(404, err); // what is the correct status code here
		} else {
			response.send(200, results);
		}
		return(next());
	});
});

server.put('/draft', function insertDraft(request, response, next) {
	console.log('Save Draft ' + request.params);
	database.insertDraft(request.params, function(err, results) {
		if (err) {
			response.send(409, err);
		} else {
			response.send(200, results);
		}
		return(next());
	});
});

server.post('/draft', function updateDraft(request, response, next) {
	console.log('Save Draft ' + request.params);
	database.updateDraft(request.params, function(err, results) {
		if (err) {
			response.send(404, err);
		} else {
			response.send(200, results);
		}
		return(next());
	});
});

server.del('/draft', function deleteDraft(request, response, next) {
	console.log('Delete Draft ' + request.params);
	database.deleteDraft(request.params, function(err, results) {
		if (err) {
			response.send(404, err);
		} else {
			response.send(200, results);
		}
		return(next());
	});
});

server.get('/draft/:messageId', function getDraft(request, response, next) {
	console.log('Get Draft ' + request.params);
	database.selectDraft(request.params, function(err, results) {
		if (err) {
			response.send(404, err);
		} else {
			response.send(200, results || {});
		}
		return(next());
	});
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
	response.send(400, 'No Valid Route ' + request.url);
	return(next());
}

