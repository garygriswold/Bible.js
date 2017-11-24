


"use strict";
var fs = require('fs');
var S3 = require('aws-sdk/clients/s3');


var uploadAudio = function(callback) {
	
	var DIRECTORY = process.env.HOME + "/ShortSands/DBL/FCBH_Audio/";
	var BUCKET_SUFFIX = "shortsands.com";
	
	var awsOptions = {
		useDualstack: true,
		sslEnabled: true,
		s3ForcePathStyle: true,
		signatureVersion: 'v4'
	};
	var s3 = new S3(awsOptions);
	
	var dirs = fs.readdirSync(DIRECTORY);
	readNextDirectory(dirs, function() {
		console.log("DONE READ NEXT DIRECTORY");
	});
	
	function readNextDirectory(directoryList, callback) {
		var dir = directoryList.shift();
		if (dir) {
			var fullname = DIRECTORY + dir;
			var stat = fs.statSync(fullname);
			if (dir.charAt() != '.' && stat.isDirectory()) {
				console.log(dir);
				var fileList = fs.readdirSync(fullname);
				readNextFile(fullname, fileList, function() {
					readNextDirectory(directoryList, callback);
				});
			} else {
				readNextDirectory(directoryList, callback);
			}
		} else {
			callback();
		}
		
	}
	function readNextFile(directory, fileList, callback) {
		var file = fileList.shift();
		if (file) {
			console.log(file);
			var s3Bucket = computeS3Bucket(file);
			var s3Key = computeS3Key(file);
			console.log(s3Bucket, s3Key);
			uploadFile(s3Bucket, s3Key, directory, file, function() {
				readNextFile(directory, fileList, callback);
			});
		} else {
			callback();
		}
	}
	
	function computeS3Bucket(filename) {
		var lastPart = filename.substr(21).split('.');
		var damId = lastPart[0];
		var s3Bucket = damId.toLowerCase() + "." + BUCKET_SUFFIX;
		return(s3Bucket);	
	}
	
	/**
	* Translate the name into a valid S3 key
	* { id }/{bookNumber}_{ USFMCode }_{ chapterNumber }.mp3
	*/
	function computeS3Key(filename) {
		var type = filename.charAt(0);
		var bookOrder = filename.substr(1, 2);
		var chapter = filename.substr(5, 3);
		if (chapter.charAt(0) == '_') chapter = "0" + chapter.substr(1, 2);
		var bookName = filename.substr(9, 12);
		bookName = bookName.replace(/_/g, '');
		var lastPart = filename.substr(21).split('.');
		var damId = lastPart[0];
		var fileType = (lastPart.length > 1) ? lastPart[1] : "";
		var baseFilename = filename.replace(/_/g, "");
		var chapterOrig = (bookName == "Psalms") ? chapter : chapter.substr(1,2);
		var myFileName = type + bookOrder + chapterOrig + bookName + damId + "." + fileType;
		if (baseFilename !== myFileName) {
			console.log(baseFilename);
			console.log(myFileName);
			process.exit(1);
		}
		var s3Key = bookNum(type, bookOrder) + "_" + usfmBookId(bookName) + "_" + chapter + "." + fileType;
		return(s3Key);
	}	
	
	function bookNum(type, bookOrder) {
		if (type == 'A') {
			return(bookOrder);
		} else if (type == 'B') {
			var num = parseInt(bookOrder) + 50;
			return(num.toString());
		} else {
			errorMessage({message: type}, "UNEXPECTED TYPE");
		}
	}
	
	function usfmBookId(bookCode) {
		var books = {
			'Genesis':   	'GEN',
			'Exodus':  		'EXO',
			'Leviticus':   	'LEV',
			'Numbers':   	'NUM',
			'Deuteronomy':  'DEU',
			'Joshua':  		'JOS',
			'Judges':  		'JDG',
			'Ruth':  		'RUT',
			'1Samuel':  	'1SA',
			'2Samuel':  	'2SA',
			'1Kings':  		'1KI',
			'2Kings':  		'2KI',
			'1Chronicles':  '1CH',
			'2Chronicles':  '2CH',
			'Ezra':  		'EZR',
			'Nehemiah':   	'NEH',
			'Esther':  		'EST',
			'Job':   		'JOB',
			'Psalms':    	'PSA',
			'Proverbs':  	'PRO',
			'Ecclesiastes': 'ECC',
			'SongofSongs':  'SNG',
			'Isaiah':   	'ISA',
			'Jeremiah':   	'JER',
			'Lamentations': 'LAM',
			'Ezekiel':  	'EZK',
			'Daniel':   	'DAN',
			'Hosea':   		'HOS',
			'Joel':  		'JOL',
			'Amos':  		'AMO',
			'Obadiah':  	'OBA',
			'Jonah': 		'JON',
			'Micah':   		'MIC',
			'Nahum':   		'NAM',
			'Habakkuk':   	'HAB',
			'Zephaniah':  	'ZEP',
			'Haggai':   	'HAG',
			'Zechariah':  	'ZEC',
			'Malachi':   	'MAL',
			'Matthew':  	'MAT',
			'Mark':  		'MRK',
			'Luke':  		'LUK',
			'John':  		'JHN',
			'Acts':  		'ACT',
			'Romans':   	'ROM',
			'1Corinthians': '1CO',
			'2Corinthians': '2CO',
			'Galatians':   	'GAL',
			'Ephesians':   	'EPH',
			'Philippians':  'PHP',
			'Colossians':   'COL',
			'1Thess':		'1TH',
			'2Thess':		'2TH',
			'1Timothy':  	'1TI',
			'2Timothy':  	'2TI',
			'Titus': 		'TIT',
			'Philemon':  	'PHM',
			'Hebrews':   	'HEB',
			'James':   		'JAS',
			'1Peter':  		'1PE',
			'2Peter':  		'2PE',
			'1John': 		'1JN',
			'2John': 		'2JN',
			'3John': 		'3JN',
			'Jude':  		'JUD',
			'Revelation':   'REV'
		};
		var result = books[bookCode];
		if (!result) {
			errorMessage({message: bookCode}, "UNKNOWN BOOK NAME");
		}
		return(result);
	}
	
	function uploadFile(bucket, key, directory, filename, callback) {
		var fullname = directory + "/" + filename;
		console.log("**" + fullname);
		fs.readFile(fullname, function(err, content) {
			if (err) {
				errorMessage(err, "FILE READ ERROR");
			} else {
				ensureBucket(bucket, function() {
					s3.putObject({Bucket: bucket, Key: key, Body: content, ContentType: 'audio/mp3'}, function(err) {
						if (err) {
							errorMessage(err, "S3 UPLOAD ERROR");
						}
						callback();
					});
				});
			}
		});
	}
	
	function ensureBucket(bucket, callback) {
		s3.headBucket({Bucket: bucket}, function(err, data) {
			if (err) {
				var location = "us-west-2"; // Needs to be set somehow!
				var params = { Bucket: bucket };
				params.CreateBucketConfiguration = { LocationConstraint: location }
 				s3.createBucket(params, function(err, data) {
 					if (err) {
	 					errorMessage(err, "Bucket Create Error");
 					} else {
	 					callback();
 					}
 				});
			} else {
				callback();
			}
 		});
	}
	
	function errorMessage(error, message) {
		console.log('ERROR', message, JSON.stringify(error.message));
		process.exit(1);
	}
};



uploadAudio(function() {
	console.log('DONE WITH UPLOAD');
});