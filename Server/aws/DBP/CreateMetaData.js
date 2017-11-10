/**
* This program reads metadata from the DBP server, and generates
* .json files that can be uploaded to S3.
* 1. Manually lookup the DBP language code for each sil language that I have in Versions.db
* 2. The DBP_lang_code should be added to Versions.db Languages table
* 3. Perform a volume list query for each Language, and store the required volume information in flat files.
* 4. Perform a book list query for each damid, and store the required data in flat files.
* 5. Perform a verse position query for each damid/book/chapter, and store the required data in flat files.
* 6. Once this all works well, should I create an option to upload each file as it is created?
*/

"use strict";
var http = require('http');
var file = require('fs');


var createMetaData = function(callback) {
	
	var HOST = "http://dbt.io/";
	var KEY = "key=b37964021bdd346dc602421846bf5683&v=2";
	var DIRECTORY = "output/";
	
	var silLangList = ['cmn'];
	var languageList = [];
	var damIdList = [];
	var chapterList = [];
	
	languageList = findAllLanguages(silLangList);
	console.log(languageList);
	
	doAllLanguages(languageList, function() {
		console.log(damIdList);
		doAllVolumes(damIdList, function() {
			doAllChapters(chapterList, function() {
				callback();
			});
		});
	});
	
	function findAllLanguages(silLangList) {
		var list = [];
		for (var i=0; i<silLangList.length; i++) {
			var sil = silLangList[i];
			var code = getLanguageCode(sil);
			list.push(code);
		}
		return list;
	}
	
	function doAllLanguages(languageList, callback) {
		var language = languageList.shift();
		if (language) {
			doVolumeListQuery(language, function() {
				doAllLanguages(languageList, callback);
			});
		} else {
			callback();	
		}
	}
	
	function doVolumeListQuery(languageCode, callback) {
		var url = HOST + "library/volume?" + KEY + "&media=audio&language_code=" + languageCode;
		httpGet(url, function(json) {
			console.log(json.length);
			var nameList = ['dam_id', 'language_code', 'language_iso_1', 'language_iso', 'version_code', 'version_name', 'version_english', 'collection_code', 'media'];
			var jsonResult = copyData(nameList, json);
			var filename = DIRECTORY + 'LANG_' + languageCode + '.json';
			writeFile(filename, jsonResult);
			for (var i=0; i<jsonResult.length; i++) {
				var result = jsonResult[i];
				damIdList.push(result.dam_id);
			}
			callback();
		});
	}
	
	function doAllVolumes(damIdList, callback) {
		var damId = damIdList.shift();
		if (damId) {
			doBookListQuery(damId, function() {
				doAllVolumes(damIdList, callback);
			});
		} else {
			callback();
		}
	}
	
	function doBookListQuery(damId, callback) {
		var url = HOST + "library/book?" + KEY + "&dam_id=" + damId;
		httpGet(url, function(json) {
			console.log(json.length);
			var nameList = ['book_id', 'book_name', 'book_order', 'number_of_chapters'];
			var jsonResult = copyData(nameList, json);
			for (var i=0; i<jsonResult.length; i++) {
				var result = jsonResult[i];
				result['book_id'] = getUSFMBookCode(result.book_id);
			}
			var filename = DIRECTORY + 'VOLUME_' + damId + '.json';
			writeFile(filename, jsonResult);
			for (i=0; i<jsonResult.length; i++) {
				result = jsonResult[i];
				result['dam_id'] = damId;
				chapterList.push(result);
			}
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
		httpGet(query, function(json) {
			// parse json
			// generate json
			// generate filename
			// write file
			callback();	
		});	
	}
	
	/**
	* Return a DBP language code, when given an SIL code as used by the App
	* This should be deprecated by adding a DBP column to the versions.db
	* language table.
	*/
	function getLanguageCode(code) {
		var languages = {
			'awa': 'AWA', // Awadhi			2
			'ben': 'BNG', // Bengali		5
			'bul': 'BLG', // Bulgarian		1
			'cmn': 'YUH', // Chinese ZHO, CHI and CMN have none	0
						  // CH1 4 text, 2 audio, Chuukese
						  // YUH 8 text, 5 audio, Cantonese
			'eng': 'ENG', // English		13
			'hin': 'HND', // Hindi			3
			'hrv': 'SRC', // Croatian		1
			'hun': 'HUN', // Hungarian		3
			'ind': 'INZ', // Indonesian		3
			'kan': 'ERV', // Kannada		2
			'mar': 'MAR', // Marathi		2
			'nep': 'NEP', // Nepali			1
			'ori': 'ORY', // Oriya			2
			'pan': 'PAN', // Punjabi		0
			'por': 'POR', // Portuguese		4
			'rus': 'RUS', // Russian		3
			'srp': 'SRP', // Serbian		0
			'spa': 'SPN', // Spanish		7
			'tam': 'TCV', // Tamil			2
			'tha': 'THA', // Thai			2
			'ukr': 'UKR', // Ukrainian		1
			'vie': 'VIE', // Vietnamese		3
			'arb': 'ARB', // Arabic			4
			'pes': 'PES', // Persian		1
			'urd': 'URD', // Urdu			2
		};
		return(languages[code]);
	}
	
	/**
	* Return the USFM book code when given the OSIS book code
	*/
	function getUSFMBookCode(bookCode) {
		var books = {
			'Gen':   'GEN',
			'Exod':  'EXO',
			'Lev':   'LEV',
			'Num':   'NUM',
			'Deut':  'DEU',
			'Josh':  'JOS',
			'Judg':  'JDG',
			'Ruth':  'RUT',
			'1Sam':  '1SA',
			'2Sam':  '2SA',
			'1Kgs':  '1KI',
			'2Kgs':  '1CH',
			'2Chr':  '2CH',
			'Ezra':  'EZR',
			'Neh':   'NEH',
			'Esth':  'EST',
			'Job':   'JOB',
			'Ps':    'PSA',
			'Prov':  'PRO',
			'Eccl':  'ECC',
			'Song':  'SNG',
			'Isa':   'ISA',
			'Jer':   'JER',
			'Lam':   'LAM',
			'Ezek':  'EZK',
			'Dan':   'DAN',
			'Hos':   'HOS',
			'Joel':  'JOL',
			'Amos':  'AMO',
			'Obad':  'OBA',
			'Jonah': 'JON',
			'Mic':   'MIC',
			'Nah':   'NAM',
			'Hab':   'HAB',
			'Zeph':  'ZEP',
			'Hag':   'HAG',
			'Zech':  'ZEC',
			'Mal':   'MAL',
			'Matt':  'MAT',
			'Mark':  'MRK',
			'Luke':  'LUK',
			'John':  'JHN',
			'Acts':  'ACT',
			'Rom':   'ROM',
			'1Cor':  '1CO',
			'2Cor':  '2CO',
			'Gal':   'GAL',
			'Eph':   'EPH',
			'Phil':  'PHP',
			'Col':   'COL',
			'1Thess':'1TH',
			'2Thess':'2TH',
			'1Tim':  '1TI',
			'2Tim':  '2TI',
			'Titus': 'TIT',
			'Phlm':  'PHM',
			'Heb':   'HEB',
			'Jas':   'JAS',
			'1Pet':  '1PE',
			'2Pet':  '2PE',
			'1John': '1JN',
			'2John': '2JN',
			'3John': '3JN',
			'Jude':  'JUD',
			'Rev':   'REV'
		};
		return(books[bookCode]);
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
	
	function copyData(nameList, json) {
		var array = [];
		for (var i=0; i<json.length; i++) {
			var result = {};
			var item = json[i];
			for (var n=0; n<nameList.length; n++) {
				var name = nameList[n];
				result[name] = item[name];
			}
			array.push(result);
		}
		return array;
	}
	
	function writeFile(filename, data) {
		var json = JSON.stringify(data, null, '\t');
		file.writeFile(filename, json, 'utf8', function(err) {
			if (err) {
				errorMessage(err, filename);
			}
		});
	}
	
	function errorMessage(error, message) {
		console.log('ERROR', message, JSON.stringify(error.message));
		process.exit(1);
	}
};


createMetaData(function() {
	console.log('DONE WITH CREATE META DATA');
});


