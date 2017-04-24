/**
* This is a command line Node program that accesses the Jesus Film API, and
* populates the tables JesusFilm and Video with data from the App.
*
* It first finds all country codes in the World using the Region table
* so that it can lookup in the API for all countries.
* Next, it finds all of the sil codes (3 char lang codes) that is used in the
* Bible App.  So, that it will extract data only for those languages.
* Next, it pulls the language code data from the JesusFilm Api for all
* country codes and selecting languages.
*/
"use strict";

// 28672 Mar 20 12:37 Versions.db It contains only Video table
// 143360 Mar 20 13:36 Versions.db
// Jesus Film is 114,688


function JesusFilmImporter() {
    var sqlite3 = require('sqlite3').verbose();
	this.database = new sqlite3.Database('Versions.db');
	this.database.exec("PRAGMA foreign_keys = ON");
	this.includeVideos = { "1_jf-0-0": true, "1_wl-0-0": true, "1_cl-0-0": true };
	Object.freeze(this);
}
JesusFilmImporter.prototype.buildJesusFilmTable = function(callback) {
	var that = this;
	getDatabaseCountries(function(countryList) {
		getDatabaseLanguages(function(langMap) {
			createJesusFilmTable(function() {
				getJesusFilmAPI(0, countryList, langMap, function() {
					console.log('DONE BUILD JESUS FILM');
					callback();
				});	
			});
		});
	});
	
	function getDatabaseCountries(callback) {
		var statement = 'SELECT countryCode, countryName FROM Region';
		that.database.all(statement, [], function(err, rows) {
			if (err) {
				that.errorHandler(err, "VideoDBApp.select Region");
			} else {
				callback(rows);
			}
		});
	}
	
	function getDatabaseLanguages(callback) {
		var statement = 'SELECT silCode, langCode, direction FROM Language';
		that.database.all(statement, [], function(err, rows) {
			if (err) {
				that.errorHandler(err, "VideoDBApp.select Language");
			} else {
				var result = {};
				for (var i=0; i<rows.length; i++) {
					var row = rows[i];
					result[row.silCode] = row;
				}
				callback(result);
			}
		});
	}
	
	function createJesusFilmTable(callback) {
		var statement = "DROP TABLE IF EXISTS JesusFilm";
		that.database.run(statement, [], function(err) {
			if (err) {
				that.errorHandler(err, "DROP JesusFilm");
			}
			statement = "CREATE TABLE JesusFilm (" +
					" countryCode TEXT NOT NULL," +
					" silCode TEXT NOT NULL," +
					" languageId TEXT NOT NULL," +
					" langCode TEXT NOT NULL," +
					" langName TEXT NOT NULL," +
					" population INT NOT NULL," +
					" PRIMARY KEY(countryCode, silCode, languageId))";
			that.database.run(statement, [], function(err) {
				if (err) {
					that.errorHandler(err, "VideoDBApp.CREATE JesusFilmLangId");
				}
				callback();
			});
		});
	}
	
	function getJesusFilmAPI(index, countryList, langMap, callback) {
		if (index < countryList.length) {
			var ctry = countryList[index];
			console.log('DOING ', index, ctry.countryCode, ctry.countryName);
			getLanguageByCountry(ctry.countryCode, langMap, function(languages) {
				storeLanguages(0, languages, function() {
					getJesusFilmAPI(index + 1, countryList, langMap, callback);					
				});
			});
		} else {
			callback();
		}
	}
	
	function getLanguageByCountry(countryCode, langMap, callback) {
		var langList = [];
		var url = 'https://api.arclight.org/v2/media-countries/' + countryCode + '?expand=mediaLanguages&metadataLanguageTags=en';
		that.getRequest(url, function(country) {
			if (country && country._embedded && country._embedded.mediaLanguages) {
				var languages = country._embedded.mediaLanguages;
				for (var index in languages) {
					var lang = languages[index];
					//console.log('LANG2', lang);
					if (langMap[lang.iso3]) {
						var result = {countryCode: countryCode, silCode: lang.iso3, langCode: langMap[lang.iso3].langCode, 
								name: lang.name, languageId: lang.languageId, population: lang.counts.countrySpeakerCount.value};
						console.log(JSON.stringify(result));
						langList.push(result);
					}
				}
			}
			callback(langList);
		});	
	}

	
	function storeLanguages(index, languages, callback) {
		if (index < languages.length) {
			var lang = languages[index];
			var statement = 'INSERT INTO JesusFilm (countryCode, silCode, languageId, langCode, langName, population) VALUES (?,?,?,?,?,?)';
			that.database.run(statement, [lang.countryCode, lang.silCode, lang.languageId, lang.langCode, lang.name, lang.population], function(err) {
				if (err) {
					that.errorHandler(err, "VideoDBApp.storeLanguages");
				}
				storeLanguages(index + 1, languages, callback);
			});
		} else {
			callback();
		}
	}
};

JesusFilmImporter.prototype.buildVideoTable = function(callback) {
	var that = this;
	getDatabaseLanguageId(function(langList) {
		//langList.length = 10;/// DEBUG
		console.log('LANGLIST', langList);
		getAvailableMedia(0, langList, function() {
			console.log('BUILD VIDEO TABLE DONE');
			callback();
		});
	});
	
	function getDatabaseLanguageId(callback) {
		var statement = 'SELECT distinct languageId, silCode, langCode FROM JesusFilm';
		that.database.all(statement, [], function(err, rows) {
			if (err) {
				that.errorHandler(err, "VideoDBApp.getDatabaseLanguageId");
			} else {
				callback(rows);
			}
		});
	}
	
	function getAvailableMedia(index, langList, callback) {
		if (index < langList.length) {
			var lang = langList[index];
			console.log('LANG', lang);
			var url = 'https://api.arclight.org/v2/media-components?limit=10&subTypes=featureFilm&languageIds=' + lang.languageId + 
						'&metadataLanguageTags=en';
			that.getRequest(url, function(components) {
				var component = components._embedded.mediaComponents;
				var videos = [];
				for (var idx in component) {
					var mediaId = component[idx].mediaComponentId;
					if (that.includeVideos[mediaId]) {
						var result = {languageId: lang.languageId, mediaId: mediaId, silCode: lang.silCode, langCode: lang.langCode };
						videos.push(result);
					}
				}
				getMetaData(videos, function() {
					getAvailableMedia(index + 1, langList, callback);
				});
			});			
		} else {
			callback();
		}
	}
	
	function getMetaData(videos, callback) {
		var video = videos.shift();
		if (video) {
			getDescriptions(video, function() {
				getMediaURLs(video, function() {
					storeAvailableMedia(video, function() {
						getMetaData(videos, callback);
					});
				});		
			});
		} else {
			callback();
		}
	}
	
	function getDescriptions(video, callback) {
		console.log('VIDEO', video);
		var url = 'https://api.arclight.org/v2/media-components/' + video.mediaId + '?metadataLanguageTags=' + video.langCode + ',en';
		that.getRequest(url, function(description) {
			video.title = description.title;
			video.longDescription = description.longDescription;
			video.lengthMS = description.lengthInMilliseconds;
			callback();
		});	
	}
	
	function getMediaURLs(video, callback) {
		var url = 'https://api.arclight.org/v2/media-components/' + video.mediaId + '/languages/' + video.languageId + 
					'?platform=ios';
		that.getRequest(url, function(components) {
			var component = components.streamingUrls;
			//console.log('IOS', JSON.stringify(component));
			var prop;
			if (component) {
				video.HLS_URL = component.m3u8[0].url;
				console.log('HLS', video.HLS_URL);
			}
			url = 'https://api.arclight.org/v2/media-components/' + video.mediaId + '/languages/' + video.languageId + 
					'?platform=android';
			that.getRequest(url, function(components) {
				component = components.streamingUrls;
				//console.log('Android', JSON.stringify(component));
				if (component) {
					video.MP4_360 = component.http[1].url;
					video.MP4_540 = component.http[2].url;
					video.MP4_720 = component.http[3].url;
					video.MP4_1080 = component.http[4].url;
				}
				callback();
			});
		});	
	}
	
	function storeAvailableMedia(video, callback) {
		var statement = "INSERT INTO Video (languageId, mediaId, silCode, langCode, title, lengthMS, HLS_URL," + 
			"MP4_1080, MP4_720, MP4_540, MP4_360, longDescription) Values (?,?,?,?,?,?,?,?,?,?,?,?)";
		var row = [video.languageId, video.mediaId, video.silCode, video.langCode, video.title, video.lengthMS, 
					video.HLS_URL, video.MP4_1080, video.MP4_720, video.MP4_540, video.MP4_360, video.longDescription];
		console.log('ROW', row);
		that.database.run(statement, row, function(err) {
			if (err) {
				that.errorHandler(err, "VideoDBApp.insert into Video");
			}
			callback();
		});
	}
};

JesusFilmImporter.prototype.getRequest = function(url, callback) {
	url += '&apiKey=' + getApiKey('ios');
	var https = require('https');
	https.get(url, function(response) {

		response.setEncoding('utf8');
		var result = '';
		response.on('data', function(chunk) { 
  			result += chunk;
  		});
		response.on('end', function() {
			try {
				var parsedData = JSON.parse(result);
				callback(parsedData);
			} catch (e) {
				console.log('PARSE ERROR ', e.message);
				callback(e);
			}
		});
	}).on('error', function(e) {
		console.log('HTTPS ERROR ', e.message);
		callback(e);
	});
	
	function getApiKey(device) {
		switch(device) {
			case 'ios':
				return('585c557d846f52.04339341');
			case 'android':
				return('585c561760c793.95483047');
			default:
				return('');
		}
	}
};

JesusFilmImporter.prototype.errorHandler = function(err, source) {
	console.log('ERROR:', source, JSON.stringify(err));
	process.exit(1);
};


var dbApp = new JesusFilmImporter();
dbApp.buildJesusFilmTable(function() {
	dbApp.buildVideoTable(function() {});	
});
