/**
* This program reads metadata from the DBP server, and generates
* .json files that can be uploaded to S3.
* 1. Manually lookup the DBP language code for each sil language that I have in Versions.db
* 2. The DBP_lang_code must be added to Versions.db Languages table
* 3. Perform a volume list query for each Language, and store the required volume information in flat files.
* 4. Perform a book list query for each damid, and store the required data in flat files.
* 5. Perform a verse position query for each damid/book/chapter, and store the required data in flat files.
* 6. Once this all works well, should I create an option to upload each file as it is created?
*/

"use strict";
var http = require('http');


var createMetaData = function(callback) {
	
	var silLangList = [];
	var languageList = [];
	var damIdList = [];
	var chapterList = [];
	
	languageList = findAllLanguages(silLangList);	
	doAllLanguages(languageList, function() {
		doAllVolumes(damIdList, function() {
			doAllChapters(chapterList, function() {
				callback();
			});
		});
	});
	
	function findAllLanguages(silLangList) {
		// iterate over my list of language codes, lookup DBP codes
		// generate languageList
		return [];
	}
	
	function doAllLanguages(languageList, callback) {
		var language = languageList.shift();
		if (language) {
			doVolumeListQuery(language, function() {
				doAllLanguages(languageList);
			});
		} else {
			callback();	
		}
	}
	
	function doVolumeListQuery(languageCode, callback) {
		// form query
		var query = "";
		getMetaData(query, function(json) {
			// parse JSON
			// generate JSON
			// include silLangCode in result
			// append each damId to damIdList
			// generate filename
			// write file for each languageCode
			callback();
		});
	}
	
	function doAllVolumes(damIdList, callback) {
		// use same logic as doAllVolumeList
		callback();
	}
	
	function doBookListQuery(damId, callback) {
		// form query
		var query = "";
		getMetaData(query, function(json) {
			// parse json
			// translate OSIS book code to USFM book code
			// generate json
			// append {damId: '', bookId: '', lastChapter: n } to chapterList
			// generate filename
			// write file
			callback();
		});
	}
	
	function doAllChapters(chapterList, callback) {
		// use same logic as doAllChapterList	
		// except you must iterate over each chapter up to the last in a book.
		callback();
	}
	
	function doVerseListQuery(damId, book, chapter, callback) {
		// form query
		var query = "";
		getMetaData(query, function(json) {
			// parse json
			// generate json
			// generate filename
			// write file
			callback();	
		});	
	}
	
	/**
	* Return a DBP language code, when given an SIL code as used by the App
	*/
	function getLanguageCode(code) {
		// use static initializer for silcode to DBP, an
		// lookup code
		//return {
        //width : width,
        //height : height,
        //ratio : width / height,
        //resize : function (newWidth) {
        //    this.width = newWidth;
        //    this.height = newWidth / this.ratio;
        //}
        return("");
	}
	
	/**
	* Return the USFM book code when given the OSIS book code
	*/
	function getUSFMBookCode(bookCode) {
		// use static initialized map of OSIS to USFM book code	
		return("");
	}
	
	function getMetaData(query, callback) {
		callback();
	}
	
	function httpGet(url, callback) {
		http.get(url, function(response) {
		  	if (response.statusCode !== 200) {
		    	var error = new Error('Request Failed. + Status Code: ' + response.statusCode);
				response.resume();
				errorMessage(error, url);
				return;
		  	}
		
		  	response.setEncoding('utf8');
		  	var rawData = '';
		  	response.on('data', function(chunk) { rawData += chunk; });
		  	response.on('end', function() {
		    	try {
		      		callback(JSON.parse(rawData));
		    	} catch (e) {
		      		errorMessage(e, url);
		    	}
		  	});
		}).on('error', function(e) {
		  errorMessage(e, url);
		});
	}
	
	function writeFile(filename, data) {
		// write file sync
	}
	
	function errorMessage(error, message) {
		console.log('ERROR', message, JSON.stringify(error.message));
		process.exit(1);
	}
};


createMetaData(function() {
	console.log('DONE WITH CREATE META DATA');
});


