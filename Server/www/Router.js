/**
* This class is the front-end of the server, and performs all routing
* to individual controllers.
*/
"use strict";
var EthnologyController = require('./EthnologyController');
var ethnologyController = new EthnologyController();

var DatabaseAdapter = require('./DatabaseAdapter');
var database = new DatabaseAdapter({filename: './TestDatabase.db', verbose: false});

var AuthController = require('./AuthController');
var authController = new AuthController(database);

var log = require('./Logger');
//log.init('BibleApp.log');

var restify = require('restify');
var server = restify.createServer({
	name: 'BibleJS',
	version: "1.0.0"
});

server.use(restify.bodyParser({
	maxBodySize: 10000,
	mapParams: true
}));

// don't forget server.use(restify.throttle);

server.pre(restify.pre.userAgentConnection()); // if UA is curl, close connection.

/**
* This pre-step is to authorize transactions.
*/
server.pre(function(request, response, next) {
	var path = request.getPath().substr(1,5);
	if (path === 'bible' || path === 'versi' || path === 'quest' || path === 'respo' || path === 'login') return(next());
	authController.authenticate(request, function(err) {
		return(next(err));
	});
});

server.on('after', function(request, response, route, error) {
	var date = new Date();
	var duration = date.getTime() - request.time();
	var msg = { time: date.toISOString(), method: request.method, url: request.url, body: request.body, statusCode: response.statusCode, duration: duration };
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
		respond(err, {'message': 'AutoTestDatabase.db created'}, 201, response, next);
		authController.database = database;
	});
});

server.get(/\/bible\/?.*/, restify.serveStatic({
	directory: '../../StaticRoot'
}));

server.get('/versions/:locale', function getVersions(request, response, next) {
	var results = ethnologyController.availVersions(request.params.locale);
	respond(null, results, 200, response, next);
});

server.get('/login', function loginTeacher(request, response, next) {
	authController.login(request, function(err, results) {
		respond(err, results, 200, response, next);
	});
});

server.put('/user', function registerTeacher(request, response, next) {
	request.params.authorizerId = request.headers.authId;
	authController.register(request.params, function(err, results) {
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

server.get('/open/:versionId', function openQuestionCount(request, response, next) {
	authController.authorizeVersion(request.headers.authId, request.params.versionId, function(err) {
		if (err) {
			return(next(err));
		} else {
			request.params.teacherId = request.headers.authId;
			database.getAssignment(request.params, function(err, results) {
				if (err || results.length > 0) {
					respond(err, results, 200, response, next);
				} else {
					database.openQuestionCount(request.params, function(err, results) {
						respond(err, results, 200, response, next);
					});
				}
			});
		}	
	});
});
/** versionId, optional timestamp */
server.post('/assign', function assignQuestion(request, response, next) {
	authController.authorizeVersion(request.headers.authId, request.params.versionId, function(err) {
		if (err) {
			return(next(err));
		} else {
			request.params.teacherId = request.headers.authId;
			database.getAssignment(request.params, function(err, results) {
				if (err || results.length > 0) {
					respond(err, results, 200, response, next);
				} else {
					database.assignQuestion(request.params, function(err, results) {
						respond(err, results, 200, response, next);
					});
				}
			});	
		}
	});
});
/** versionId, discourseId */
server.post('/return', function returnQuestion(request, response, next) {
	authController.authorizeVersion(request.headers.authId, request.params.versionId, function(err) {
		if (err) {
			return(next(err));
		} else {
			request.params.teacherId = request.headers.authId;
			database.returnQuestion(request.params, function(err, results) {
				if (err) {
					respond(err, results, 200, response, next);
				} else {
					database.openQuestionCount(request.params, function(err, results) {
						respond(err, results, 200, response, next);
					});			
				}
			});	
		}
	});
});
/** versionId, discourseId */
server.post('/another', function anotherQuestion(request, response, next) {
	authController.authorizeVersion(request.headers.authId, request.params.versionId, function(err) {
		if (err) {
			return(next(err));
		} else {
			request.params.teacherId = request.headers.authId;
			database.returnQuestion(request.params, function(err, results) {
				if (err || results === undefined || results.timestamp === undefined) {
					respond(err, results, 200, response, next);
				} else {
					request.params.timestamp = results.timestamp; // set to assign a later question.
					database.assignQuestion(request.params, function(err, results) {
						respond(err, results, 200, response, next);
					});
				}
			});	
		}
	});
});

server.post('/answer', function sendAnswer(request, response, next) {
	authController.authorizeVersion(request.headers.authId, request.params.versionId, function(err) {
		if (err) {
			return(next(err));
		} else {
			request.params.teacherId = request.headers.authId;
			database.saveAnswer(request.params, function(err, saveResults) {
				if (err) {
					respond(err, saveResults, 200, response, next);			
				} else {
					database.openQuestionCount(request.params, function(err, results) {
						results.rowCount = saveResults.rowCount;
						results.messageTimestamp = saveResults.timestamp;
						respond(err, results, 200, response, next);
					});
				}
			});	
		}
	});
});

server.del('/answer', function deleteAnswer(request, response, next) {
	database.deleteAnswer(request.params, function(err, results) {
		respond(err, results, 200, response, next);
	});
});

server.get('/response/:discourseId', function getAnswers(request, response, next) {
	database.selectAnswer(request.params, function(err, results) {
		respond(err, results, 200, response, next);
	});
});

server.post('/draft', function saveDraft(request, response, next) {
	database.saveDraft(request.params, function(err, results) {
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
		if (! error.statusCode) {
			error.statusCode = errorStatusCode(error);
		}
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
		if (message.indexOf('Register') > -1) return(400);
	}
	return(500);
}
