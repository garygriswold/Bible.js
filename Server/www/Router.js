/**
* This class is the front-end of the server, and performs all routing
* to individual controllers.
*/
"use strict";
var EthnologyController = require('./EthnologyController');
var ethnologyController = new EthnologyController();

var DatabaseAdapter = require('./DatabaseAdapter');
var database = new DatabaseAdapter({filename: './TestDatabase.db', verbose: true});

var log = require('./Logger');
//log.init('BibleApp.log');

var restify = require('restify');
var server = restify.createServer({
	name: 'BibleJS',
	version: "1.0.0"
});
server.pre(restify.pre.userAgentConnection()); // if UA is curl, close connection.

server.use(restify.bodyParser({
	maxBodySize: 10000,
	mapParams: true
}));

server.on('after', function(request, response, route, error) {
	var date = new Date();
	var msg = { time: date.toISOString(), method: request.method, url: request.url, body: request.body, statusCode: response.statusCode };
	if (error) {
		msg.error = error;
		log.error(msg);
	} else {
		log.info(msg);
	}
});

/**
* This route should be commented out of a production server.
*/
server.get('/beginTest', function beginTest(request, response, next) {
	database = new DatabaseAdapter({filename: './AutoTestDatabase.db', verbose: true});
	database.create(function(err) {
		respond(err, {"message":"AutoTestDatabase.db created"}, 201, response, next);
	});
});

server.get(/\/bible\/?.*/, restify.serveStatic({
	directory: '../../StaticRoot'
}));

server.get('/versions/:locale', function getVersions(request, response, next) {
	var result = ethnologyController.availVersions(request.params.locale);
	response.send(200, result);
	return(next());	
});

server.put('/user', function registerTeacher(request, response, next) {
	database.insertTeacher(request.params, function(err, results) {
		respond(err, results, 201, response, next);
	});
});

server.post('/user', function updateTeacher(request, response, next) {
	database.updateTeacher(request.params, function(err, results) {
		respond(err, results, 200, response, next);
	});
});

server.del('/user/', function deleteTeacher(request, response, next) {
	database.deleteTeacher(request.params, function(err, results) {
		respond(err, results, 200, response, next);
	});
});

server.put('/position', function insertPosition(request, response, next) {
	database.insertPosition(request.params, function(err, results) {
		respond(err, results, 201, response, next);
	});
});

server.post('/position', function updatePosition(request, response, next) {
	database.updatePosition(request.params, function(err, results) {
		respond(err, results, 200, response, next);
	});
});

server.del('/position', function deletePosition(request, response, next) {
	database.deletePosition(request.params, function(err, results) {
		respond(err, results, 200, response, next);
	});
});

server.put('/question', function insertQuestion(request, response, next) {
	database.insertQuestion(request.params, function(err, results) {
		respond(err, results, 201, response, next);
	});
});

server.post('/question', function updateQuestion(request, response, next) {
	database.updateQuestion(request.params, function(err, results) {
		respond(err, results, 200, response, next);
	});
});

server.del('/question', function deleteQuestion(request, response, next) {
	database.deleteQuestion(request.params, function(err, results) {
		respond(err, results, 200, response, next);
	});
});

server.get('/open/:teacherId/:versionId', function openQuestionCount(request, response, next) {
	database.getAssignment(request.params, function(err, results) {
		if (err || results.length > 0) {
			respond(err, results, 200, response, next);
		} else {
			database.openQuestionCount(request.params, function(err, results) {
				respond(err, results, 200, response, next);
			});
		}
	});
});

server.get('/assign/:teacherId/:versionId', function assignQuestion(request, response, next) {
	database.assignQuestion(request.params, function(err, results) {
		respond(err, results, 200, response, next);
	});
});

server.get('/return/:versionId/:discourseId', function returnQuestion(request, response, next) {
	database.returnQuestion(request.params, function(err, results) {
		if (err) {
			respond(err, results, 200, response, next);
		} else {
			database.openQuestionCount(request.params, function(err, results) {
				respond(err, results, 200, response, next);
			});			
		}
	});
});

server.get('/another/:teacherId/:versionId/:discourseId', function anotherQuestion(request, response, next) {
	database.returnQuestion(request.params, function(err, results) {
		if (err) {
			respond(err, results, 200, response, next);
		} else {
			database.assignQuestion(request.params, function(err, results) {
				respond(err, results, 200, response, next);
			});
		}
	});
});

server.put('/answer', function insertAnswer(request, response, next) {
	database.insertAnswer(request.params, function(err, results) {
		if (err) {
			respond(err, results, 201, response, next);			
		} else {
			var timestamp = results.timestamp;
			database.openQuestionCount(request.params, function(err, results) {
				results.messageTimestamp = timestamp;
				respond(err, results, 201, response, next);
			});
		}
	});
});

server.post('/answer', function updateAnswer(request, response, next) {
	database.updateAnswer(request.params, function(err, results) {
		respond(err, results, 200, response, next);
	});
});

server.del('/answer', function deleteAnswer(request, response, next) {
	database.deleteAnswer(request.params, function(err, results) {
		respond(err, results, 200, response, next);
	});
});

server.get('/answer/:discourseId', function getAnswers(request, response, next) {
	database.selectAnswer(request.params, function(err, results) {
		respond(err, results, 200, response, next);
	});
});

server.put('/draft', function insertDraft(request, response, next) {
	database.insertDraft(request.params, function(err, results) {
		respond(err, results, 201, response, next);
	});
});

server.post('/draft', function updateDraft(request, response, next) {
	database.updateDraft(request.params, function(err, results) {
		respond(err, results, 200, response, next);
	});
});

server.del('/draft', function deleteDraft(request, response, next) {
	database.deleteDraft(request.params, function(err, results) {
		respond(err, results, 200, response, next);
	});
});

server.get('/draft/:discourseId/:timestamp', function getDraft(request, response, next) {
	database.selectDraft(request.params, function(err, results) {
		respond(err, results, 200, response, next);
	});
});

server.listen(8080, function() {
	console.log('listening on 8080');
});

function respond(error, results, successCode, response, next) {
	if (error) {
		error.statusCode = errorStatusCode(error);
		return(next(error));
	} else {
		response.send(successCode, results);
		return(next());
	}
}
/**
* I need to extend error so that I have a code that I can use in a language independent way to identify errors
*/
function errorStatusCode(err) {
	var message = err.message;
	if (message) {
		if (message.indexOf('SQLITE_CONSTRAINT') > -1) return(409);
		if (message.indexOf('actual=0') > -1) return(410);
		if (message.indexOf('expected=2  actual=1') > -1) return(410);
		if (message.indexOf('no questions') > -1) return(410);
	}
	return(500);
}
