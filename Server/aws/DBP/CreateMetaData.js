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
	
	/**
	* This table should be moved to the Version table with two new fields
	* dbp_lang, and dbp_version
	*/
	var versions = {
			// America
			'ERV-ENG': ['ENG', 'WEB', false ],
			'KJVPD':   ['ENG', 'KJV', true ],
			'WEB':     ['ENG', 'WEB', true ],
			'ERV-POR': ['POR', 'ARA', false ],
			'ERV-SPA': ['SPN', 'WTC', true ], // or R95 or BDA
			// East Asia
			'ERV-CMN': ['YUH', 'UNV', false ], // or CHN, UNV 
			'ERV-IND': ['INZ', 'SHL', false ],
			'ERV-NEP': ['NEP', null, false ],
			'ERV-THA': ['THA', null, false ],
			'ERV-VIE': ['VIE', null, false ],
			// Middle East
			'ARBVDPD': ['ARB', 'WTC', false ],
			'ERV-ARB': ['ARB', 'WTC', true ],
			'NMV':     ['PES', null, false ],
			// India
			'ERV-AWA': ['AWA', 'WTC', true ],
			'ERV-BEN': ['BNG', 'WTC', true ],
			'ERV-HIN': ['HND', 'WTC', true ],
			'ERV-KAN': ['ERV', 'WTC', true ],
			'ERV-MAR': ['MAR', null, false ],
			'ERV-ORI': ['ORY', null, false ],
			'ERV-PAN': ['PAN', null, false ],
			'ERV-TAM': ['TCV', 'WTC', true ],
			'ERV-URD': ['URD', 'WTC', true ], // or PAK
			// Eastern Europe
			'ERV-BUL': ['BLG', 'AMB', false ],
			'ERV-HRV': ['SRC', null, false ],
			'ERV-HUN': ['HUN', 'HBS', false ],
			'ERV-RUS': ['RUS', 'S76', false ],
			'ERV-SRP': ['SRP', null, false ],
			'ERV-UKR': ['UKR', 'O95', false ]
	};
	
	var versionList = Object.getOwnPropertyNames(versions);
	console.log("VERS " + versionList);
	var damIdList = [];
	var bookList = [];
	var audioTableSql = [];
	var audioBookTableSql = [];
	var versePositions = {};
	
	doAllVersions(versionList, function() {
		console.log(damIdList);
		doAllVolumes(damIdList, function() {
			doAllChapters(bookList, function() {
				callback();
			});
		});
	});
	
	function doAllVersions(versionList, callback) {
		var version = versionList.shift();
		if (version) {
			var DBPData = versions[version];
			var dbpLanguage = DBPData[0];
			var dbpVersion = DBPData[1];
			console.log("LANG " + dbpLanguage + "  VERS " + dbpVersion);
			doVolumeListQuery(version, dbpLanguage, dbpVersion, function() {
				//versionList = []; // DEBUG
				doAllVersions(versionList, callback);
			});
		} else {
			var filename = DIRECTORY + 'AudioTable.sql';
			console.log(audioTableSql);
			writeSQLFile(filename, audioTableSql);			
			callback();	
		}
	}
	
	function doVolumeListQuery(version, dbpLanguage, dbpVersion, callback) {
		var url = HOST + "library/volume?" + KEY + "&media=audio&language_code=" + dbpLanguage;
		httpGet(url, function(json) {
			console.log("Before Prune " + json.length);
			var jsonVersion = pruneListByVersion(json, dbpVersion);
			console.log("After Prune " + jsonVersion.length);			
			console.log(jsonVersion);
			var nameList = ['dam_id', 'language_code', 'version_code', 'collection_code', 'media_type', 'volume_name' ];
			var sqlResult = insertStmt('Audio', nameList, jsonVersion);
			for (var r=0; r<sqlResult.length; r++) {
				var row = sqlResult[r];
				row.push(", '");
				row.push(version);
				row.push("', '");
				var date = new Date().toISOString().substr(0, 10);
				row.push(date);
				row.push("');");
				console.log(row.join(''));
				audioTableSql.push(row.join(''));
			}
			callback();
		});
	}
	
	function pruneListByVersion(volumeList, versionCode) {
		var result = [];
		for (var i=0; i<volumeList.length; i++) {
			var volume = volumeList[i];
			if (volume.version_code == versionCode) {
				result.push(volume);
				damIdList.push(volume.dam_id);
				
			}
		}
		return(result);
	}
	
	function doAllVolumes(damIdList, callback) {
		var damId = damIdList.shift();
		if (damId) {
			doBookListQuery(damId, function() {
				doAllVolumes(damIdList, callback);
			});
		} else {
			var filename = DIRECTORY + 'AudioBookTable.sql';
			writeSQLFile(filename, audioBookTableSql);
			callback();
		}
	}

	function doBookListQuery(damId, callback) {
		var url = HOST + "library/book?" + KEY + "&dam_id=" + damId;
		httpGet(url, function(json) {
			console.log(json.length);
			for (var i=0; i<json.length; i++) {
				var result = json[i];
				result.usfm_book_id = getUSFMBookCode(result.book_id);
				bookList.push(result);
			}
			var nameList = ['dam_id', 'usfm_book_id', 'book_order', 'number_of_chapters'];
			var sqlResult = insertStmt('AudioBook', nameList, json);

			for (i=0; i<sqlResult.length; i++) {
				var row = sqlResult[i];
				row.push(");");
				console.log(row.join(''));
				audioBookTableSql.push(row.join(''));
			}
			callback();
		});
	}
	
	function doAllChapters(bookList, callback) {
		var book = bookList.shift();
		if (book) {
			versePositions = {};
			var numOfChapters = 0 + book.number_of_chapters;
			doEachChapter(book, 1, numOfChapters, callback);
		} else {
			callback();
		}
	}
	
	function doEachChapter(book, chapterNum, numOfChapters, callback) {
		if (chapterNum <= numOfChapters) {
			doVerseListQuery(book.dam_id, book.book_id, chapterNum, function() {
				doEachChapter(book, chapterNum + 1, numOfChapters, callback);
			});
		} else {
			var usfm_book_id = getUSFMBookCode(book.book_id);
			var filename = DIRECTORY + 'Verse_' + book.dam_id + '_' + book.book_order + '_' + usfm_book_id + '.json';
			writeJsonFile(filename, versePositions);			
			callback();
		}
	}
	
	function doVerseListQuery(damId, book_id, chapter, callback) {
		damId = 'ENGESVN2DA';
		var url = HOST + "audio/versestart?" + KEY + "&dam_id=" + damId + "&osis_code=" + book_id + "&chapter_number=" + chapter;
		httpGet(url, function(json) {
			var row = {};
			for (var i=0; i<json.length; i++) {
				var item = json[i];
				row[item.verse_id] = item.verse_start;
				//versePositions.push(row);
				versePositions[chapter] = row;
			}
			callback();	
		});	
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
	
	function insertStmt(table, columnList, json) {
		var array = [];
		for (var i=0; i<json.length; i++) {
			var row = [];
			var item = json[i];
			row.push("INSERT INTO ");
			row.push(table);
			row.push(" VALUES(");
			for (var n=0; n<columnList.length; n++) {
				if (n > 0) {
					row.push(', ');
				}
				var col = columnList[n];
				row.push("'");
				row.push(item[col]);
				row.push("'");
			}
			array.push(row);
		}
		return array;
	}
	
	function writeJsonFile(filename, data) {
		var json = JSON.stringify(data, null, '\t');
		file.writeFile(filename, json, 'utf8', function(err) {
			if (err) {
				errorMessage(err, filename);
			}
		});
	}
	
	function writeSQLFile(filename, array) {
		file.writeFile(filename, array.join('\n'), 'utf8', function(err) {
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


