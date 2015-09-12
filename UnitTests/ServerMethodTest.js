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
		var expected = JSON.stringify(test.results);
		if (status == test.status && results == expected) {
			console.log('OK', test.name);
			console.log('FOUND:', status, results);
		} else {
			console.log('EXPECTED:', test);
			console.log('FOUND:', status, results);
			process.exit(1);
		}
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
		path: '/user/ABCDEFGHIJ',	
		status: 200,
		results: {rowCount:1, lastID:2}
	},
		{
		name: 'deleteTeacher',
		description: 'Delete non-existing teacher',
		method: 'DELETE',
		path: '/user/ABCDEFG',	
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
		results:  {message:'expected=1  actual=0'}
	}
]

var runTest = new ServerMethodTest('localhost', 8080);
runTest.runTests();
