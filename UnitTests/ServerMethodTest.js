/**
* This command-line executable node program is a test harness for the server.
* It runs a series of automated tests, and produces stdout output showing the
* results.  It stops on the first error found, and only runs to completion
* when there are no errors.
*/
function ServerMethodTest(server, port) {
	this.server = server;
	this.port = port;
}
ServerMethodTest.prototype.runTests = function() {
	var that = this;
	runTest(0);
	
	function runTest(index) {
		if (index < tests.length) {
			sendTestToServer(tests[index], function(status, results) {
				compareResponse(tests[index], status, results);
				runTest(index + 1);
			});
		} else {
			console.log('\n\nOK DONE');
		}
	}
	
	function sendTestToServer(test, callback) {
		var postData = (test.postData) ? JSON.stringify(test.postData) : null;
		
		options = {
			hostname: that.server,
			port: that.port,
			method: test.method,
			path: test.path,
			agent: false };
		if (postData) {
			dataHeaders = {
				'Content-Type': 'application/json',
				'Content-Length': postData.length
			}
			options.headers = dataHeaders;
		}
		
		var http = require('http');
		var request = http.request(options, function(response) {
			response.setEncoding('utf8');
			var results = '';
			response.on('data', function (chunk) {
				results += chunk;
  			});
  			response.on('end', function() {
  				callback(response.statusCode, results);
  			});
		});

		request.on('error', function(err) {
			console.log('problem with request: ' + err.message);
			callback(0, err);
		});

		if (postData) {
			request.write(postData);
		}
		request.end();
	}
	
	function compareResponse(test, status, results) {
		if (status != test.status) {
			displayError(test, status, results);
		}
		var actual = removeChangeableFields(results);
		if (actual != JSON.stringify(test.results)) {
			displayError(test, status, results);	
		} else {
			console.log('OK', test.name);
			console.log('FOUND:', status, results);			
		}
	}
	
	function removeChangeableFields(results) {
		var actual = JSON.parse(results);
		if (actual.length) {
			for (var i=0; i<actual.length; i++) {
				delete actual[i]['timestamp'];
			}
		} else {
			delete actual['timestamp'];
		}
		return(JSON.stringify(actual));
	}
	
	function displayError(test, status, results) {
		console.log('EXPECTED:', test);
		console.log('FOUND:', status, results);
		process.exit(1);		
	}
};

var tests = [
	{
		name: 'beginTests',
		description: 'Initialize server for testing',
		method: 'GET',
		path: '/beginTest',
		status: 201,
		results: {message:'AutoTestDatabase.db created'}
	},
	{
		name: 'getVersions',
		description: 'A Valid getVersions call',
		method: 'GET',
		path: '/versions/en-US',
		postData: null,
		status: 200,
		results: ['WEB.bible1','KJV.bible1']
	},
	{
		name: 'getVersions',
		description: 'A Valid getVersions call, but it should be invalid in the future',
		method: 'GET',
		path: '/versions/es-ES',
		postData: null,
		status: 200,
		results: ['WEB.bible1','KJV.bible1']		
	},
	{
		name: 'registerTeacher',
		description: 'A Valid registerTeacher call',
		method: 'PUT',
		path: '/user',
		postData: {teacherId:'ABCDE', fullname:'Gary Griswold', pseudonym:'Gary G', signature:'XXXX', versionId:'KJV'},
		status: 201,
		results: {rowCount:2, lastID:1}
	},
	{
		name: 'registerTeacher',
		description: 'A 2nd Valid registerTeacher call',
		method: 'PUT',
		path: '/user',
		postData: {teacherId:'ABCDEFGHIJ', fullname:'Gary Norris', pseudonym:'Gary G2', signature:'XXXX', versionId:'KJVA'},
		status: 201,
		results: {rowCount:2, lastID:2}	
	},
	{
		name: 'registerTeacher',
		description: 'Duplicate registerTeacher call',
		method: 'PUT',
		path: '/user',
		postData: {teacherId:'ABCDEFGHIJ', fullname:'Gary Norris', pseudonym:'Gary G2', signature:'XXXX', versionId:'KJVA'},
		status: 409,
		results: {message:'SQLITE_CONSTRAINT: UNIQUE constraint failed: Teacher.teacherId'}
	},
	{
		name: 'updateTeacher',
		description: 'Valid updateTeacher call',
		method: 'POST',
		path: '/user',
		postData: {teacherId:'ABCDE', fullname:'Gary N Griswold', pseudonym:'Gary N'},
		status: 200,
		results: {rowCount:1, lastID:2}
	},
	{
		name: 'updateTeacher',
		description: 'Update non-existent teacher',
		method: 'POST',
		path: '/user',
		postData: {teacherId:'AB', fullname:'Gary N Griswold', pseudonym:'Gary N'},
		status: 410,
		results: {message:'expected=1  actual=0'}
	},
	{
		name: 'deleteTeacher',
		description: 'Delete existing teacher',
		method: 'DELETE',
		path: '/user',
		postData: {teacherId: 'ABCDEFGHIJ'},
		status: 200,
		results: {rowCount:1, lastID:2}
	},
		{
		name: 'deleteTeacher',
		description: 'Delete non-existing teacher',
		method: 'DELETE',
		path: '/user',
		postData: {teacherId: 'ABCXXX'},	
		status: 410,
		results: {message:'expected=1  actual=0'}
	},
	{
		name: 'insertPosition',
		description: 'Insert valid position',
		method: 'PUT',
		path: '/position',
		postData: {teacherId:'ABCDE', position:'super', versionId:'KJVA'},
		status: 201,
		results: {rowCount:1, lastID:2}
	},
	{
		name: 'insertPosition',
		description: 'Insert duplicate position',
		method: 'PUT',
		path: '/position',
		postData: {teacherId:'ABCDE', position:'super', versionId:'KJVA'},
		status: 409,
		results: {message:'SQLITE_CONSTRAINT: UNIQUE constraint failed: Position.versionId, Position.teacherId'}	
	},
	{
		name: 'updatePosition',
		description: 'Update valid position',
		method: 'POST',
		path: '/position',
		postData: {teacherId:'ABCDE', versionId:'KJVA', position:'removed'},
		status: 200,
		results: {rowCount:1, lastID:2}
	},
	{
		name: 'updatePosition',
		description: 'Update position with invalid position value',
		method: 'POST',
		path: '/position',
		postData: {teacherId:'ABCDE', versionId:'KJVA', position:'XXXX'},
		status: 409,
		results: {message:'SQLITE_CONSTRAINT: CHECK constraint failed: Position'}	
	},
	{
		name: 'deletePosition',
		description: 'Delete existing position',
		method: 'DELETE',
		path: '/position',
		postData: {teacherId:'ABCDE', versionId:'KJVA'},
		status: 200,
		results: {rowCount:1, lastID:2}
	},
	{
		name: 'deletePosition',
		description: 'Delete already deleted position',
		method: 'DELETE',
		path: '/position',
		postData: {teacherId:'ABCDE', versionId:'KJVA'},
		status: 410,
		results: {message:'expected=1  actual=0'}
	},
	{
		name: 'insertQuestion',
		description: 'Insert a new valid question',
		method: 'PUT',
		path: '/question',
		postData: {discourseId:'12345', versionId:'KJV', reference:'John1', message:'This is my questions'},
		status: 201,
		results: {rowCount:2, lastID:1}
	},
	{
		name: 'updateQuestion',
		description: 'Update an existing question',
		method: 'POST',
		path: '/question',
		postData: {messageId:1, reference:'John3', message:'This is my revised questions'},
		status: 200,
		results: {rowCount:1, lastID:1}
	},
	{
		name: 'updateQuestion',
		description: 'Attempt to update non-existing question',
		method: 'POST',
		path: '/question',
		postData: {messageId:100, reference:'John3', message:'This is my revised questions'},
		status: 410,
		results: {message:'expected=1  actual=0'}
	},
	{
		name: 'deleteQuestion',
		description: 'Delete existing question',
		method: 'DELETE',
		path: '/question',
		postData: {discourseId:'12345'},
		status: 200,
		results: {rowCount:1, lastID:1}	
	},
	{
		name: 'deleteQuestion',
		description: 'Delete already deleted question',
		method: 'DELETE',
		path: '/question',
		postData: {discourseId:'12345'},
		status: 410,
		results: {message:'expected=1  actual=0'}
	},
	{
		name: 'insertQuestion',
		description: 'Re-insert a valid question after deletion',
		method: 'PUT',
		path: '/question',
		postData: {discourseId:'12345', versionId:'KJV', reference:'John1', message:'This is my questions'},
		status: 201,
		results: {rowCount:2, lastID:1}
	},
	{
		name: 'openQuestionCount',
		description: 'Incomplete Open Question Count call',
		method: 'GET',
		path: '/open/KJV',
		status: 404,
		results: {code:'ResourceNotFound', message:'/open/KJV does not exist'}
	},
	{
		name: 'openQuestionCount',
		description: 'Valid open question count request',
		method: 'GET',
		path: '/open/ABCDE/KJV',
		status: 200,
		results: {count:1}
	},
	{
		name: 'openQuestionCount',
		description: 'Open question count of non-existing version',
		method: 'GET',
		path: '/open/ABCDE/XXX',
		status: 200,
		results: {count:0}
	},
	{
		name: 'openQuestionCount',
		description: 'Open question count of non-existent version and non-existent student',
		method: 'GET',
		path: '/open/XXXXX/XXXX',
		status: 200,	// is this the correct result
		results: {count:0}	
	},
	{
		name: 'assignQuestion',
		description: 'Assign question to non-existent user',
		method: 'GET',
		path: '/assign/XXXXX/KJV',
		status: 409,
		results: {message:'SQLITE_CONSTRAINT: FOREIGN KEY constraint failed'}	
	},
	{
		name: 'assignQuestion',
		description: 'Assign existing question to valid user',
		method: 'GET',
		path: '/assign/ABCDE/KJV',
		status: 200,
		results: {discourseId:'12345', reference:'John1', message:'This is my questions'}
	},
	{
		name: 'assignQuestion',
		description: 'Assign to valid user when no questions remain',
		method: 'GET',
		path: '/assign/ABCDE/KJV',
		status: 410,
		results: {message:'There are no questions to assign.'}
	},
	{
		name: 'returnQuestion',
		description: 'Return assigned question',
		method: 'GET',
		path: '/return/12345/KJV',
		status: 200,
		results: {count:1}	
	},
	{
		name: 'returnQuestion',
		description: 'Return the same assigned question that has already been returned',
		method: 'GET',
		path: '/return/12345/KJV',
		status: 200, // Because return is an update, it succeeds when there is not change.
		results: {count:1}		
	},
	{
		name: 'assignQuestion',
		description: 'Assign to valid user again',
		method: 'GET',
		path: '/assign/ABCDE/KJV',
		status: 200,
		results: {discourseId:'12345', reference:'John1', message:'This is my questions'}	
	},
	{
		name: 'openQuestionCount',
		description: 'Attempt openQuestionCount when there is an assigned question',
		method: 'GET',
		path: '/open/ABCDE/KJV',
		status: 200,
		results: [{discourseId:'12345', versionId:'KJV', messageId:1, reference:'John1', message:'This is my questions'}]
	},
	{
		name: 'anotherQuestion',
		description: 'Assign a different question, using invalid discourseId',
		method: 'GET',
		path: '/another/ABCDE/KJV/XXXX',
		status: 410,
		results: {message:'expected=1  actual=0'}
	},
	{
		name: 'anotherQuestion',
		description: 'Assign a different question, but teacherId is invalid',
		method: 'GET',
		path: '/another/XXXXX/KJV/12345',
		status: 409,
		results: {message:'SQLITE_CONSTRAINT: FOREIGN KEY constraint failed'}
	},
	{
		name: 'anotherQuestion',
		description: 'Assign a different question, with valid input, but there are none to assign',
		method: 'GET',
		path: '/another/ABCDE/KJV/12345',
		status: 200, // assigns the same question over again, maybe this should be corrected, but it is complicated method
		results: {discourseId:'12345', reference:'John1', message:'This is my questions'}
	},
	{
		name: 'insertAnswer',
		description: 'Insert an answer with valid input',
		method: 'PUT',
		path: '/answer',
		postData: {discourseId:'12345', reference:'John6', teacherId:'ABCDE', message:'This is the answer'},
		status: 201,
		results: {count: 0}
	},
	{
		name: 'insertAnswer',
		description: 'Insert an identical answer',
		method: 'PUT',
		path: '/answer',
		postData: {discourseId:'12345', reference:'John6', teacherId:'ABCDE', message:'This is the answer'},
		status: 410,
		results: {message:'expected=2  actual=1'}	
	},
	{
		name: 'updateAnswer',
		description: 'Update an answer with valid input',
		method: 'POST',
		path: '/answer',
		postData: {messageId:2, reference:'John7', message:'This is the revised answer'},
		status: 200,
		results: {rowCount:1, lastID:3}
	},
	{
		name: 'updateAnswer',
		description: 'Update an answer with invalid messageId',
		method: 'POST',
		path: '/answer',
		postData: {messageId:1000, reference:'John7', message:'This is the revised answer'},
		status: 410,
		results:  {message:'expected=1  actual=0'}
	},
	{
		name: 'deleteAnswer',
		description: 'Delete an answer',
		method: 'DELETE',
		path: '/answer',
		postData: {messageId:2},
		status: 200,
		results: {rowCount:2, lastID:3}
	},
	{
		name: 'deleteAnswer',
		description: 'Delete an non-existent answer',
		method: 'DELETE',
		path: '/answer',
		postData: {messageId:1000},
		status: 410,
		results: {message: 'expected=1  actual=0'}		
	}
]


var runTest = new ServerMethodTest('localhost', 8080);
runTest.runTests();
