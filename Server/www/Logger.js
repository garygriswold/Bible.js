/**
* This class implements a simplified logger, which is similar to a log4j logger
* in the most basic of ways.
*/

var FS = require('fs');

var log = {
	filepath: 'stdout',
	useConsole: true,
	
	init: function(path) {
		log.filepath = path;
		log.useConsole = (path == 'stdout');
	},
	error: function(msg) {
		msg.level = 'error';
		log._log(msg);
	},
	warn: function(msg) {
		msg.level = 'warn';
		log._log(msg);
	},
	info: function(msg) {
    	msg.level = 'info';
    	log._log(msg);
  	},
  	_log: function(msg) {
		if (log.useConsole) {
			console.log(msg);
		} else {
			if (msg.error) {
				error = msg.error;
				msg.error = error.message;

				//for (var prop in error) {
				//	console.log('ERROR', '|' + prop + '|' , '{' + error[prop] + '}');
				//}
				//var part1 = error.message;
				//console.log('ERR MSG', part1);
			}
			var str = JSON.stringify(msg) + '\n';
		  	FS.appendFile(log.filepath, str, function(err) {
		  		if (err) {
			  		console.log(message);
				}  
			});
		}
  	}
};

module.exports = log;

