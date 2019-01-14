# This program reads metadata from the DBP server, and generates
# .json files that can be uploaded to S3.
# 1. Manually lookup the DBP language code for each sil language that I have in Versions.db
# 2. The DBP_lang_code should be added to Versions.db Languages table
# 3. Perform a volume list query for each Language, and store the required volume information in flat files.
# 4. Perform a book list query for each damid, and store the required data in flat files.
# 5. Perform a verse position query for each damid/book/chapter, and store the required data in flat files.
# 6. Once this all works well, should I create an option to upload each file as it is created?
#
#
#"use strict";
#var http = require('http');
#var file = require('fs');
#
#
#var audioDBPImporter = function(callback) {
#	
#	var HOST = "http://dbt.io/";
#	var KEY = "key=b37964021bdd346dc602421846bf5683&v=2";
#	var DIRECTORY = "output/";
#	
#	/**
#	* This table controls what Audio versions will be included, and what
#	* text versions that are associated with
#	*/
#	var versions = {
#			'ERV-ARB': ['ARB', 'WTC', true ], 	// ARBWTC/ARBWTCN1DA, ARBWTCO1DA
#			'ARBVDPD': ['ARZ', 'VDV', true ], 	// ARBVDV/ARZVDVN2DA, ARZVDVO2DA
#			'ERV-AWA': ['AWA', 'WTC', true ], 	// AWAWTC/AWAWTCN2DA,
#			'ERV-BEN': ['BNG', 'WTC', true ], 	// BENWTC/BNGWTCN1DA, BNGWTCN2DA
#			'ERV-BUL': ['BLG', 'AMB', false ], 	// BULPRB/BLGAMBN1DA
#			'ERV-CMN': ['CHN', 'UNV', true ], 	// CMNUN1/CHNUNVN2DA, CMNUNV/CHNUNVO2DA
#			'ERV-ENG': ['ENG', 'ESV', false ], 	// ENGESV/ENGESVN2DA, ENGESVO2DA
#			'KJVPD':   ['ENG', 'KJV', true ], 	// ENGKJV/ENGKJVN2DA, ENGKJVO2DA
#			'WEB':     ['ENG', 'WEB', true ], 	// ENGWEB/ENGWEBN2DA, ENGWEBO2DA
#			'ERV-HRV': ['SRC', null, false ],
#			'ERV-HIN': ['HND', 'WTC', true], 	// HINWTC/HNDWTCN2DA
#			'ERV-HUN': ['HUN', 'HBS', false ],	// HUNHBS/HUNHBSN1DA
#			'ERV-IND': ['INZ', 'SHL', false ],	// INDSHL/INZSHLN2DA
#			'ERV-KAN': ['ERV', 'WTC', true ],	// KANWTC/ERVWTCN1DA, ERVWTCN2DA
#			'ERV-MAR': ['MAR', 'WTC', true ],	// MARWTC/MARWTCN1DA, MARWTCN2DA
#			'ERV-NEP': ['NEP', null, false ],
#			'ERV-ORI': ['ORY', 'WTC', true ],	// ORYWTC/ORYWTCN1DA, ORYWTCN2DA
#			'ERV-PAN': ['PAN', null, false ],
#			'ERV-POR': ['POR', 'ARA', false ],	// PORBAR/PORARAN2DA
#			'ERV-RUS': ['RUS', 'S76', false ],	// RUSS76/RUSS76N2DA, RUSS76O2DA
#			'ERV-SPA': ['SPN', 'WTC', true ],	// SPAWTC/SPNWTCN2DA
#			'ERV-SRP': ['SRP', null, false ],
#			'ERV-TAM': ['TCV', 'WTC', true ],	// TAMWTC/TCVWTCN1DA
#			'ERV-THA': ['THA', null, false ],
#			'ERV-UKR': ['UKR', 'O95', false ],	// UKRN39/UKRO95N2DA
#			'ERV-URD': ['URD', 'WTC', true ],	// URDWTC/URDWTCN2DA
#			'ERV-VIE': ['VIE', null, false ],
#			'NMV':     ['PES', null, false ]
#	};
#	//versions = {
#	//	'ERV-ENG': ['ENG', 'ESV', false ]	
#	//};
#	
#	var versionList = Object.getOwnPropertyNames(versions);
#	console.log("VERS " + versionList);
#	var damIdList = [];
#	var bookList = [];
#	var audioVersionSql = [];
#	var audioTableSql = [];
#	var audioBookTableSql = [];
#	var audioChapterTableSql = [];
#	
#	doAllVersions(versionList, function() {
#		//console.log(damIdList);
#		doAllVolumes(damIdList, function() {
#			//console.log(bookList);
#			doAllChapters(bookList, function() {
#				callback();
#			});
#		});
#	});
#	
#	function doAllVersions(versionList, callback) {
#		var version = versionList.shift();
#		if (version) {
#			var DBPData = versions[version];
#			var dbpLanguage = DBPData[0];
#			var dbpVersion = DBPData[1];
#			if (dbpVersion) {
#				var sql = "INSERT INTO AudioVersion VALUES ('" + version + "', '" + 
#				dbpLanguage + "', '" + dbpVersion + "');";
#				console.log(sql);
#				audioVersionSql.push(sql);
#			}
#			doVolumeListQuery(dbpLanguage, dbpVersion, function() {
#				doAllVersions(versionList, callback);
#			});
#		} else {
#			writeSQLFile(DIRECTORY + 'AudioVersionTable.sql', audioVersionSql);
#			
#			writeSQLFile(DIRECTORY + 'AudioTable.sql', audioTableSql);
#				
#			callback();	
#		}
#	}
#	
#	function doVolumeListQuery(dbpLanguage, dbpVersion, callback) {
#		var url = HOST + "library/volume?" + KEY + "&media=audio&language_code=" + dbpLanguage;
#		httpGet(url, function(json) {
#			console.log("Before Prune " + json.length);
#			//console.log(json);
#			var jsonVersion = pruneListByVersion(json, dbpVersion);
#			console.log("After Prune " + jsonVersion.length);			
#			console.log(jsonVersion);
#			var nameList = [ 'dam_id', 'language_code', 'version_code', 'collection_code', 'media_type', 'volume_name' ];
#			var sqlResult = insertStmt('Audio', nameList, jsonVersion);
#			for (var r=0; r<sqlResult.length; r++) {
#				var row = sqlResult[r];
#				var date = new Date().toISOString().substr(0, 10);
#				row.splice(row.length - 1, 0, ", '" + date + "'");
#				console.log(row.join(''));
#				audioTableSql.push(row.join(''));
#			}
#			callback();
#		});
#	}
#	
#	function pruneListByVersion(volumeList, versionCode) {
#		var result = [];
#		for (var i=0; i<volumeList.length; i++) {
#			var volume = volumeList[i];
#			if (volume.version_code == versionCode) {
#				result.push(volume);
#				damIdList.push(volume.dam_id);
#				
#			}
#		}
#		return(result);
#	}
#	
#	function doAllVolumes(damIdList, callback) {
#		var damId = damIdList.shift();
#		if (damId) {
#			doBookListQuery(damId, function() {
#				doAllVolumes(damIdList, callback);
#			});
#		} else {
#			writeSQLFile(DIRECTORY + 'AudioBookTable.sql', audioBookTableSql);
#			callback();
#		}
#	}
#
#	function doBookListQuery(damId, callback) {
#		var url = HOST + "library/book?" + KEY + "&dam_id=" + damId;
#		httpGet(url, function(json) {
#			console.log(json.length);
#			for (var i=0; i<json.length; i++) {
#				var result = json[i];
#				if (result.book_order.length == 1) {
#					result.book_order = "0" + result.book_order;
#				}			
#				result.usfm_book_id = getUSFMBookCode(result.book_id);
#				bookList.push(result);
#			}
#			var nameList = ['dam_id', 'usfm_book_id', 'book_order', 'number_of_chapters'];
#			var sqlResult = insertStmt('AudioBook', nameList, json);
#
#			for (i=0; i<sqlResult.length; i++) {
#				var row = sqlResult[i];
#				console.log(row.join(''));
#				audioBookTableSql.push(row.join(''));
#			}
#			callback();
#		});
#	}
#	
#	function doAllChapters(bookList, callback) {
#		var book = bookList.shift();
#		if (book) {
#			console.log('Verses ' + book.dam_id + '  ' + book.book_id);
#			var numOfChapters = 0 + book.number_of_chapters;
#			doEachChapter(book, 1, numOfChapters, function() {
#				doAllChapters(bookList, callback);
#			});
#		} else {
#			writeSQLFile(DIRECTORY + 'AudioChapterTable.sql', audioChapterTableSql);
#			callback();
#		}
#	}
#	
#	function doEachChapter(book, chapterNum, numOfChapters, callback) {
#		if (chapterNum <= numOfChapters) {
#			doVerseListQuery(book, chapterNum, function(count) {
#				if (chapterNum == 1 && count == 0) {
#					callback();
#					return;
#				}
#				doEachChapter(book, chapterNum + 1, numOfChapters, callback);
#			});
#		} else {	
#			callback();
#		}
#	}
#	function doVerseListQuery(book, chapterNum, callback) {
#		var url = HOST + "audio/versestart?" + KEY + "&dam_id=" + book.dam_id + "&osis_code=" + book.book_id + "&chapter_number=" + chapterNum;
#		httpGet(url, function(json) {
#			var array = [];
#			array[0] = 0.0;
#			for (var i=0; i<json.length; i++) {
#				var item = json[i];
#				array[item.verse_id] = item.verse_start;
#			}
#			for (var j=1; j<array.length; j++) {
#				if (array[j] == null) {
#					array[j] = array[j - 1];
#				}
#			}
#			if (json.length > 0) {
#				var sql = "INSERT INTO AudioChapter VALUES('" + book.dam_id + "', '" + book.usfm_book_id + "', '" + chapterNum + "', '" + JSON.stringify(array) + "');"
#				console.log(sql);
#				audioChapterTableSql.push(sql);
#			}
#			callback(json.length);	
#		});	
#	}
#
#	/* This function generates json in an objct { 1: nn.nn, 2: nn.nn, ... }
#	function doVerseListQuery(book, chapterNum, callback) {
#		var url = HOST + "audio/versestart?" + KEY + "&dam_id=" + book.dam_id + "&osis_code=" + book.book_id + "&chapter_number=" + chapterNum;
#		httpGet(url, function(json) {
#			console.log(json);
#			var row = {};
#			for (var i=0; i<json.length; i++) {
#				var item = json[i];
#				row[item.verse_id] = item.verse_start;
#			}
#			if (json.length > 0) {
#				var sql = "INSERT INTO AudioChapter VALUES('" + book.dam_id + "', '" + book.usfm_book_id + "', '" + chapterNum + "', '" + JSON.stringify(row) + "');"
#				console.log(sql);
#				audioChapterTableSql.push(sql);
#			}
#			callback(json.length);	
#		});	
#	}
#	*/
#	
#	/**
#	* Return the USFM book code when given the OSIS book code
#	*/
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
			'2Kgs':  '2KI',
			'1Chr':  '1CH',
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
		var result = books[bookCode];
		return((result) ? result : bookCode);
	}
	
#	function httpGet(url, callback) {
#		http.get(url, function(response) {
#		  	if (response.statusCode !== 200) {
#		    	var error = new Error('Request Failed. + Status Code: ' + response.statusCode);
#				response.resume();
#				errorMessage(error, url);
#				return;
#		  	}
#		
#		  	response.setEncoding('utf8');
#		  	var rawData = '';
#		  	response.on('data', function(chunk) { rawData += chunk; });
#		  	response.on('end', function() {
#		    	try {
#		      		callback(JSON.parse(rawData));
#		    	} catch (e) {
#		      		errorMessage(e, url);
#		    	}
#		  	});
#		}).on('error', function(e) {
#		  errorMessage(e, url);
#		});
#	}
#	
#	function insertStmt(table, columnList, json) {
#		var array = [];
#		for (var i=0; i<json.length; i++) {
#			var row = [];
#			var item = json[i];
#			row.push("REPLACE INTO " + table + " VALUES (");
#			for (var n=0; n<columnList.length; n++) {
#				if (n > 0) {
#					row.push(', ');
#				}
#				var col = columnList[n];
#				row.push("'");
#				row.push(item[col]);
#				row.push("'");
#			}
#			row.push(");");
#			array.push(row);
#		}
#		return array;
#	}
#	
#	function ensureDirectory(directory) {
#		if (!file.existsSync(directory)) {
#			file.mkdirSync(directory);
#		}
#	}
#	
#	function writeSQLFile(filename, array) {
#		file.writeFile(filename, array.join('\n'), 'utf8', function(err) {
#			if (err) {
#				errorMessage(err, filename);
#			}
#		});
#	}
#	
#	function errorMessage(error, message) {
#		console.log('ERROR', message, JSON.stringify(error.message));
#		process.exit(1);
#	}
#};
#
#
#audioDBPImporter(function() {
#	console.log('DONE WITH CREATE META DATA');
#});


