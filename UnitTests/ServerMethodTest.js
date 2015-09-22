/**
* This command-line executable node program is a test harness for the server.
* It runs a series of automated tests, and produces stdout output showing the
* results.  It stops on the first error found, and only runs to completion
* when there are no errors.
*/
function ServerMethodTest(server, port) {
	this.server = server;
	this.port = port;
	this.CryptoJS = require('./lib/aes.js');
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
		options = {
			hostname: that.server,
			port: that.port,
			method: test.method,
			path: pathKeyReplace(test.path),
			agent: false 
		};
		
		var headers = {};
		var postData = dataKeyReplace(test.postData);
		if (postData) {
			headers['Content-Type'] = 'application/json';
			headers['Content-Length'] = postData.length;
		}
		
		var datetime = new Date().toString();
		headers['Date'] = datetime;
		
		if (test.user && test.passPhrase) {
			var encrypted = that.CryptoJS.AES.encrypt(datetime, test.passPhrase);
			headers['Authorization'] = 'Signature' + '  ' + test.user + '  ' + encrypted;
		}
		options.headers = headers;

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
	
	function dataKeyReplace(postData) {
		if (postData) {
			for (var prop in postData) {
				var value = postData[prop];
				if (value && (typeof value) == 'string') {
					var parts = value.split(':');
					if (parts.length > 1) {
						postData[prop] = database[parts[0]][parts[1]];
					}
				}
			}
			return(JSON.stringify(postData));
		} else {
			return(null);
		}
	}
	function pathKeyReplace(path) {
		var items = path.split('/');
		for (var i=0; i<items.length; i++) {
			var parts = items[i].split(':');
			if (parts.length > 1) {
				items[i] = database[parts[0]][parts[1]];
			}
		}
		return(items.join('/'));
	}
	
	function compareResponse(test, status, results) {
		console.log('COMPARE RESULT', results);
		var actual = JSON.parse(results);
		if (status != test.status) {
			displayError('STATUS ERROR', test, status, actual);
		}		
		if (actual.length && test.results.length) {
			if (actual.length !== test.results.length) {
				displayError('RESULT ARRAY DIFFER IN SIZE', test, status, actual);
			}
			for (var i=0; i<actual.length; i++) {
				compareObjects(test, test.results[i], status, actual[i]);
			}
		} else if (actual.length && ! test.results.length) {
			displayError('ARRAY-OBJECT MISMATCH ERROR', test, status, actual);
		} else {
			compareObjects(test, test.results, status, actual);
		}
	}
	
	function compareObjects(test, testResults, status, actual) {
		for (var prop in testResults) {
			if (! actual.hasOwnProperty(prop)) {
				displayError('RESULTS MISSING PROP ERROR', test, status, actual);
			}
			if (prop !== 'teacherId' && prop !== 'passPhrase' && prop !== 'discourseId' && prop !== 'timestamp' && prop !== 'messageTimestamp') {
				if (actual[prop] != testResults[prop]) {
					displayError('RESULTS VALUE ERROR', test, status, actual);
				}
			}
		}
		for (var prop in actual) {
			if (! testResults.hasOwnProperty(prop)) {
				displayError('TEST MISSING PROP ERROR', test, status, actual);
			}
		}
		console.log('OK', test.number, test.name);
		console.log('FOUND:', status, JSON.stringify(actual));
		if (test.save) {
			database[test.save] = actual;
		}
	}
	
	function displayError(message, test, status, actual) {
		console.log('DATABASE:', database);
		console.log(message);
		console.log('EXPECTED:', test);
		console.log('FOUND:', status, actual);
		process.exit(1);		
	}
};

var database = {};

var tests = [
	{
		number: 10,
		name: 'beginTests',
		description: 'Initialize server for testing',
		method: 'GET',
		path: '/beginTest',
		status: 201,
		results: {message:'AutoTestDatabase.db created'}
	},
	{
		number: 20,
		name: 'getVersions',
		description: 'A Valid getVersions call',
		method: 'GET',
		path: '/versions/en-US',
		postData: null,
		status: 200,
		results: ['WEB.bible1','KJV.bible1']
	},
	{
		number: 30,
		name: 'getVersions',
		description: 'A Valid getVersions call, but it should be invalid in the future',
		method: 'GET',
		path: '/versions/es-ES',
		postData: null,
		status: 200,
		results: ['WEB.bible1','KJV.bible1']		
	},
	{
		number: 40,
		name: 'registerTeacher',
		description: 'A registration with no credentials',
		method: 'PUT',
		path: '/user',
		postData: {fullname:'Bob Smith', pseudonym:'Bob S', versionId:'KJV'},
		status: 401,
		results: {message: 'Authorization Data Incomplete'}
	},
	{
		number: 41,
		name: 'registerTeacher',
		description: 'A registration with credentials, but not existent teacher',
		method: 'PUT',
		path: '/user',
		postData: {fullname:'Bob Smith', pseudonym:'Bob S', versionId:'KJV'},
		user: 'XXXXXX',
		passPhrase: 'InTheWordIsLife',
		status: 401,
		results: {message: 'Unknown TeacherId'}
	},
	{
		number: 42,
		name: 'registerTeacher',
		description: 'A registration with credentials, but not incorrect passPhrase',
		method: 'PUT',
		path: '/user',
		postData: {fullname:'Bob Smith', pseudonym:'Bob S', versionId:'KJV'},
		user: 'GNG',
		passPhrase: 'ABCDEFGHIJ',
		status: 401,
		results: {message: 'Verification Failure'}		
	},
	{
		number: 43,
		name: 'registerTeacher',
		description: 'A Valid registerTeacher call',
		method: 'PUT',
		path: '/user',
		postData: {fullname:'Bob Smith', pseudonym:'Bob S', versionId:'WEB'},
		user: 'GNG',
		passPhrase: 'InTheWordIsLife',
		status: 201,
		results: {rowCount:2, teacherId:'GUID', passPhrase:'PASS'},
		save: 'Bob'
	},
	{
		number: 50,
		name: 'registerTeacher',
		description: 'A registerTeacher call, but with unknown version',
		method: 'PUT',
		path: '/user',
		postData: {fullname:'Bill Will', pseudonym:'Bill W', versionId:'XXXX'},
		user: 'GNG',
		passPhrase: 'InTheWordIsLife',
		status: 500,
		results: {message: 'SQLITE_ERROR: no such table: concordance'}
	},
	{
		number: 60,
		name: 'registerTeacher',
		description: 'A teacher with invalid input',
		method: 'PUT',
		path: '/user',
		postData: {fullname: null, pseudonym: null, versionId:'WEB'},
		user: 'GNG',
		passPhrase: 'InTheWordIsLife',
		status: 400,
		results: {message: 'Register with fullname and pseudonym'}
	},
	{
		number: 61,
		name: 'registerTeacher',
		description: 'A teacher with invalid input',
		method: 'PUT',
		path: '/user',
		postData: {fullname: 'Bill Will', pseudonym: 'Billy', versionId:'WEB'},
		user: 'GNG',
		passPhrase: 'InTheWordIsLife',
		status: 201,
		results: {rowCount:2, teacherId:'GUID', passPhrase:'PASS'},
		save: 'Bill'
	},
	{
		number: 70,
		name: 'updateTeacher',
		description: 'Valid updateTeacher call',
		method: 'POST',
		path: '/user',
		postData: {teacherId: 'Bob:teacherId', fullname:'Bob Jones', pseudonym:'Bobby'},
		user: 'GNG',
		passPhrase: 'InTheWordIsLife',
		status: 200,
		results: {rowCount:1}
	},
	{
		number: 80,
		name: 'updateTeacher',
		description: 'Update non-existent teacher',
		method: 'POST',
		path: '/user',
		postData: {teacherId: 'XXXX', fullname:'Whoever', pseudonym:'Watt'},
		user: 'GNG',
		passPhrase: 'InTheWordIsLife',
		status: 410,
		results: {message:'expected=1  actual=0'}
	},
	{
		number: 90,
		name: 'deleteTeacher',
		description: 'Delete existing teacher',
		method: 'DELETE',
		path: '/user',
		postData: {teacherId: 'Bill:teacherId'},
		user: 'GNG',
		passPhrase: 'InTheWordIsLife',
		status: 200,
		results: {rowCount:1}
	},
	{
		number: 100,
		name: 'deleteTeacher',
		description: 'Delete non-existing teacher',
		method: 'DELETE',
		path: '/user',
		postData: {teacherId: 'XXXXX'},
		user: 'GNG',
		passPhrase: 'InTheWordIsLife',	
		status: 410,
		results: {message:'expected=1  actual=0'}
	},
	{
		number: 110,
		name: 'insertPosition',
		description: 'Insert valid position',
		method: 'PUT',
		path: '/position',
		postData: {teacherId:'Bob:teacherId', versionId:'KJVA', position:'super'},
		user: 'GNG',
		passPhrase: 'InTheWordIsLife',
		status: 201,
		results: {rowCount:1}
	},
	{
		number: 120,
		name: 'insertPosition',
		description: 'Insert duplicate position',
		method: 'PUT',
		path: '/position',
		postData: {teacherId:'Bob:teacherId', versionId:'KJVA', position:'super'},
		user: 'GNG',
		passPhrase: 'InTheWordIsLife',
		status: 409,
		results: {message:'SQLITE_CONSTRAINT: UNIQUE constraint failed: Position.versionId, Position.teacherId'}	
	},
	{
		number: 130,
		name: 'updatePosition',
		description: 'Update valid position',
		method: 'POST',
		path: '/position',
		postData: {teacherId:'Bob:teacherId', versionId:'KJVA', position:'removed'},
		user: 'GNG',
		passPhrase: 'InTheWordIsLife',
		status: 200,
		results: {rowCount:1}
	},
	{
		number: 140,
		name: 'updatePosition',
		description: 'Update position with invalid position value',
		method: 'POST',
		path: '/position',
		postData: {teacherId:'Bob:teacherId', versionId:'KJVA', position:'XXXX'},
		user: 'GNG',
		passPhrase: 'InTheWordIsLife',
		status: 409,
		results: {message:'SQLITE_CONSTRAINT: CHECK constraint failed: Position'}	
	},
	{
		number: 150,
		name: 'deletePosition',
		description: 'Delete existing position',
		method: 'DELETE',
		path: '/position',
		postData: {teacherId:'Bob:teacherId', versionId:'KJVA'},
		user: 'GNG',
		passPhrase: 'InTheWordIsLife',
		status: 200,
		results: {rowCount:1}
	},
	{
		number: 160,
		name: 'deletePosition',
		description: 'Delete already deleted position',
		method: 'DELETE',
		path: '/position',
		postData: {teacherId:'Bob:teacherId', versionId:'KJVA'},
		user: 'GNG',
		passPhrase: 'InTheWordIsLife',
		status: 410,
		results: {message:'expected=1  actual=0'}
	},
	{
		number: 170,
		name: 'insertQuestion',
		description: 'Insert a new valid question',
		method: 'PUT',
		path: '/question',
		postData: {versionId:'KJV', reference:'John1', message:'This is my questions'},
		status: 201,
		results: {rowCount:2, discourseId: 'GUID', timestamp: 'TIME'},
		save: 'Disc1'
	},
	{
		number: 180,
		name: 'updateQuestion',
		description: 'Update an existing question',
		method: 'POST',
		path: '/question',
		postData: {discourseId:'Disc1:discourseId', timestamp:'Disc1:timestamp', reference:'John3', message:'This is my revised questions'},
		status: 200,
		results: {rowCount:1}
	},
	{
		number: 190,
		name: 'updateQuestion',
		description: 'Attempt to update non-existing question',
		method: 'POST',
		path: '/question',
		postData: {discourseId:'Disc1:discourseId', timestamp:'XXXX', reference:'John3', message:'This is my revised questions'},
		status: 410,
		results: {message:'expected=1  actual=0'}
	},
	{
		number: 200,
		name: 'deleteQuestion',
		description: 'Delete existing question',
		method: 'DELETE',
		path: '/question',
		postData: {discourseId:'Disc1:discourseId', timestamp: 'Disc1:timestamp'},
		status: 200,
		results: {rowCount:1}	
	},
	{
		number: 210,
		name: 'deleteQuestion',
		description: 'Delete already deleted question',
		method: 'DELETE',
		path: '/question',
		postData: {discourseId:'Disc1:discourseId', timestamp: 'XXXXX'},
		status: 410,
		results: {message:'expected=1  actual=0'}
	},
	{
		number: 220,
		name: 'insertQuestion',
		description: 'Re-insert a valid question after deletion',
		method: 'PUT',
		path: '/question',
		postData: {versionId:'KJV', reference:'John1', message:'This is my questions'},
		status: 201,
		results: {rowCount:2, discourseId: 'GUID', timestamp: 'TIME' },
		save: 'Disc2'
	},
	{
		number: 230,
		name: 'insertQuestion',
		description: 'Insert a valid 2nd question',
		method: 'PUT',
		path: '/question',
		postData: {versionId:'KJV', reference:'John2', message:'This is another question'},
		status: 201,
		results: {rowCount:2, discourseId: 'GUID', timestamp: 'TIME' },
		save: 'Desc3'
	},
	{
		number: 240,
		name: 'insertQuestion',
		description: 'Insert a valid 3rd question',
		method: 'PUT',
		path: '/question',
		postData: {versionId:'KJV', reference:'John3', message:'This is my third question'},
		status: 201,
		results: {rowCount:2, discourseId: 'GUID', timestamp: 'TIME' },
		save: 'Desc4'		
	},
	{
		number: 250,
		name: 'openQuestionCount',
		description: 'Incomplete Open Question Count call',
		method: 'GET',
		path: '/open',
		user: 'Bob:teacherId',
		passPhrase: 'Bob:passPhrase',
		status: 404,
		results: { code: 'ResourceNotFound', message: '/open does not exist' }
	},
	{
		number: 260,
		name: 'openQuestionCount',
		description: 'Valid open question count request',
		method: 'GET',
		path: '/open/Bob:teacherId/KJV',
		user: 'Bob:teacherId',
		passPhrase: 'Bob:passPhrase',
		status: 200,
		results: {count:3, timestamp: 'TIME'}
	},
	{
		number: 270,
		name: 'openQuestionCount',
		description: 'Open question count of non-existing version',
		method: 'GET',
		path: '/open/Bob:teacherId/XXX',
		user: 'Bob:teacherId',
		passPhrase: 'Bob:passPhrase',
		status: 200,
		results: {count:0, timestamp: null}
	},
	{
		number: 280,
		name: 'openQuestionCount',
		description: 'Open question count of non-existent version and non-existent teacher',
		method: 'GET',
		path: '/open/XXXXX/XXXX',
		user: 'Bob:teacherId',
		passPhrase: 'Bob:passPhrase',
		status: 200,
		results: {count:0, timestamp:null}	
	},
	{
		number: 290,
		name: 'assignQuestion',
		description: 'Assign question to non-existent user',
		method: 'POST',
		path: '/assign',
		postData: {teacherId:'XXXXX', versionId:'KJV'},
		status: 409,
		results: {message:'SQLITE_CONSTRAINT: FOREIGN KEY constraint failed'}	
	},
	{
		number: 300,
		name: 'assignQuestion',
		description: 'Assign existing question to valid user',
		method: 'POST',
		path: '/assign',
		postData: {teacherId:'Bob:teacherId', versionId:'KJV'},
		status: 200,
		results: {discourseId:'GUID', versionId:'KJV', person:'S', timestamp: 'TIME', reference:'John1', message:'This is my questions'},
		save: 'Assign'
	},
	{
		number: 310,
		name: 'assignQuestion',
		description: 'Assign attempt when there is already one assign, should get already assigned ',
		method: 'POST',
		path: '/assign',
		postData: {teacherId:'Bob:teacherId', versionId:'KJV'},
		status: 200,
		results: [{discourseId:'GUID', versionId:'KJV', person:'S', timestamp:'TIME', reference:'John1', message:'This is my questions'}],
	},
	{
		number: 320,
		name: 'assignQuestion',
		description: 'Assign attempt when there is already one assign using timestamp, should get already assigned ',
		method: 'POST',
		path: '/assign',
		postData: {teacherId:'Bob:teacherId', versionId:'KJV', timestamp:'Assign:timestamp'},
		status: 200,
		results: [{discourseId:'GUID', versionId:'KJV', person:'S', timestamp:'TIME', reference:'John1', message:'This is my questions'}],
	},
	{
		number: 330,
		name: 'returnQuestion',
		description: 'Return assigned question',
		method: 'POST',
		path: '/return',
		postData: {teacherId:'Bob:teacherId', versionId:'KJV', discourseId:'Disc2:discourseId'},
		status: 200,
		results: {count:3, timestamp: 'TIME'}	
	},
	{
		number: 340,
		name: 'assignQuestion',
		description: 'Assign without timestamp to get same question again',
		method: 'POST',
		path: '/assign',
		postData: {teacherId:'Bob:teacherId', versionId:'KJV'}, //timestamp:'Assign:timestamp'},
		status: 200,
		results: {discourseId:'GUID', versionId:'KJV', person:'S', timestamp:'TIME', reference:'John1', message:'This is my questions'},
		save: 'Assign'				
	},
	{
		number: 350,
		name: 'returnQuestion',
		description: 'Return assigned question',
		method: 'POST',
		path: '/return',
		postData: {teacherId:'Bob:teacherId', versionId:'KJV', discourseId:'Assign:discourseId'},
		status: 200,
		results: {count:3, timestamp: 'TIME'}		
	},
	{
		number: 360,
		name: 'assignQuestion',
		description: 'Assign to valid user when no questions remain',
		method: 'POST',
		path: '/assign',
		postData: {teacherId:'Bob:teacherId', versionId:'KJV', timestamp:'Assign:timestamp'},
		status: 200,
		results: {discourseId:'GUID', versionId:'KJV', person:'S', timestamp:'TIME', reference:'John2', message:'This is another question'},
		save: 'Assign'		
	},
	///{
	//	number: 310,
	//	name: 'returnQuestion',
	//	description: 'Return the same assigned question that has already been returned',
	//	method: 'POST',
	//	path: '/return',
	//	postData: {versionId:'KJV', discourseId:'Assign:discourseId'},
	//	status: 200,
	//	results: {count:3, timestamp: 'TIME'}		
	//},
	//{
	//	number: 320,
	//	name: 'assignQuestion',
	//	description: 'Assign to valid user again',
	//	method: 'POST',
	//	path: '/assign',
	//	postData: {teacherId:'Bob:teacherId', versionId:'KJV'},
	//	status: 200,
	//	results: {discourseId:'GUID', versionId:'KJV', person:'S', timestamp:'TIME', reference:'John1', message:'This is my questions'}	
	//},
	{
		number: 370,
		name: 'openQuestionCount',
		description: 'Attempt openQuestionCount when there is an assigned question',
		method: 'GET',
		path: '/open/Bob:teacherId/KJV',
		status: 200,
		results: [{discourseId:'GUID', versionId:'KJV', person:'S', timestamp:'TIME', reference:'John2', message:'This is another question'}]
	},
	{
		number: 380,
		name: 'anotherQuestion',
		description: 'Assign a different question, using invalid discourseId',
		method: 'POST',
		path: '/another',
		postData: {teacherId:'Bob:teacherId', versionId:'KJV', discourseId:'XXXX'},
		status: 410,
		results: {message:'expected=1  actual=0'}
	},
	{
		number: 390,
		name: 'anotherQuestion',
		description: 'Assign a different question, but teacherId is invalid',
		method: 'POST',
		path: '/another',
		postData: {teacherId:'XXXXX', versionId:'KJV', discourseId:'Disc2:discourseId'},
		status: 410,
		results: {message: 'expected=1  actual=0'}
	},
	{
		number: 400,
		name: 'anotherQuestion',
		description: 'Assign a different question, with valid input',
		method: 'POST',
		path: '/another',
		postData: {teacherId:'Bob:teacherId', versionId:'KJV', discourseId:'Assign:discourseId'},
		status: 200,
		results: {discourseId:'GUID', versionId:'KJV', person:'S', timestamp:'TIME', reference:'John3', message:'This is my third question'},
		save: 'Assign'
	},
	{
		number: 410,
		name: 'anotherQuestion',
		description: 'Assign a different question, with valid input, but no more questions',
		method: 'POST',
		path: '/another',
		postData: {teacherId:'Bob:teacherId', versionId:'KJV', discourseId:'Assign:discourseId'},
		status: 410,
		results: {message: 'There are no questions to assign.'},
		save: 'Assign'		
	},
	{
		number: 420,
		name: 'sendAnswer',
		description: 'Insert an answer with valid input',
		method: 'POST',
		path: '/answer',
		postData: {discourseId:'Disc2:discourseId', reference:'John6', teacherId:'Bob:teacherId', message:'This is the answer'},
		status: 200,
		results: {count: 0, timestamp: null, rowCount: 2, messageTimestamp: 'TIME'},
		save: 'Msg2'
	},
	{
		number: 430,
		name: 'sendAnswer',
		description: 'Insert an identical answer',
		method: 'POST',
		path: '/answer',
		postData: {discourseId:'Disc2:discourseId', reference:'John6', teacherId:'Bob:teacherId', message:'This is a repeated answer'},
		status: 200,
		results: {count: 0, timestamp: null, rowCount: 2, messageTimestamp: 'TIME'}	
	},
	{
		number: 440,
		name: 'sendAnswer',
		description: 'Update an answer with valid input',
		method: 'POST',
		path: '/answer',
		postData: {discourseId:'Disc2:discourseId', timestamp:'Msg2:messageTimestamp', reference:'John7', message:'This is the revised answer'},
		status: 200,
		results: {count: 0, timestamp: null, rowCount: 2, messageTimestamp: 'TIME'}
	},
	{
		number: 450,
		name: 'sendAnswer',
		description: 'Update an answer with invalid discourseId',
		method: 'POST',
		path: '/answer',
		postData: {discourseId:'XXXXX', reference:'John7', message:'This is the revised answer'},
		status: 409,
		results: {message: 'SQLITE_CONSTRAINT: FOREIGN KEY constraint failed'}
	},
	{
		number: 460,
		name: 'deleteAnswer',
		description: 'Delete an answer',
		method: 'DELETE',
		path: '/answer',
		postData: {discourseId:'Disc2:discourseId', timestamp:'Msg2:messageTimestamp'},
		status: 200,
		results: {rowCount: 2}
	},
	{
		number: 470,
		name: 'deleteAnswer',
		description: 'Delete an non-existent answer',
		method: 'DELETE',
		path: '/answer',
		postData: {discourseId:'Disc2:discourseId', timestamp:'Msg2:messageTimestamp'},
		status: 410,
		results: {message: 'expected=2  actual=1'}		
	},
	{
		number: 480,
		name: 'saveDraft',
		description: 'Insert a valid draft answer',
		method: 'POST',
		path: '/draft',
		postData: {discourseId:'Disc2:discourseId', reference:'John8', message:'Save this incomplete answer till later'},
		status: 200,
		results: {rowCount: 1, timestamp:'TIME'},
		save: 'Draft1'	
	},
	{
		number: 490,
		name: 'saveDraft',
		description: 'Update a valid draft answer',
		method: 'POST',
		path: '/draft',
		postData: {discourseId:'Disc2:discourseId', timestamp:'Draft1:timestamp', reference:'John9', message:'Revised again'},
		status: 200,
		results: {rowCount: 1, timestamp:'TIME'}		
	},
	{
		number: 500,
		name: 'deleteDraft',
		description: 'Delete a valid draft answer',
		method: 'DELETE',
		path: '/draft',
		postData: {discourseId:'Disc2:discourseId', timestamp:'Draft1:timestamp'},
		status: 200,
		results: {rowCount: 1}		
	}
]


var runTest = new ServerMethodTest('localhost', 8080);
runTest.runTests();
