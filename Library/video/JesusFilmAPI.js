/**
* This is a test and demonstration program that reads in locale information
* and uses it to access Jesus Film Meta Data, and parses out data that is 
* needed for processing.
*
* function getDescription returns the following images under imageURL
* thumbnail: Jesus Face, 120x68 8bit, brightcove
* videoStill: Jesus Face, 480x270 8bit, brightcove
* hd: DVD Cover, 336x480 8bit, cloudfront
* mobileCinematicHigh: Jesus Face, 640x300 8bit, cloudfront
* mobileCinematicLow: Jesus Face, 320x150 8bit, cloudfront
* medium: DVD Cover, 112x160 8bit, cloudfront
* small: DVD Cover, 63x90 8bit, cloudfront
* banner440x250: Jesus Face 440x250 8bit, cloudfront
* banner600x338: Jesus Face 600x338 8bit, cloudfront
* banner800x412: Jesus Face 880x412 8bit, cloudfront
* banner880x441: Jesus Face 880x441 8bit, cloudfront
* mobileCinematicVeryLow: unknown format, cloudfront
*/
"use strict";

function JesusFilmAPI(deviceType, countryCode, silCode, lang2Code) {
	this.deviceType = deviceType.toLowerCase();
	this.apiKey = getApiKey(this.deviceType);
	this.countryCode = countryCode;
	this.silCode = silCode;
	this.lang2Code = lang2Code;
	this.languageId = null;
	Object.seal(this);
	
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
}
JesusFilmAPI.prototype.getMetaData = function(callback) {
	var that = this;
	getLanguageId(function(langId) {
		that.languageId = langId;
		if (langId) {
			getMediaAvailable(langId, function(idList) {
				callback(idList);
			});
		} else {
			callback([]);
		}
	});
	function getLanguageId(callback) {
		getLanguageByCountry(function(langId) {
			if (langId) {
				callback(langId);
			} else {
				getLanguage(function(langId) {
					callback(langId);
				});
			}
		});		
	}
	function getLanguageByCountry(callback) {
		var languageId = null;
		var url = 'https://api.arclight.org/v2/media-countries/' + that.countryCode + '?expand=mediaLanguages&metadataLanguageTags=en';
		that.httpsGet(url, function(country) {
			if (country && country._embedded && country._embedded.mediaLanguages) {
				var languages = country._embedded.mediaLanguages;
				for (var prop in languages) {
					if (languages[prop].iso3 === that.silCode) {
						languageId = languages[prop].languageId;
						console.log('LANGUAGE ID ' + languageId);
					}
				}
			}
			callback(languageId);
		});	
	}
	function getLanguage(callback) {
		var languageId = null;
		var url = 'https://api.arclight.org/v2/media-languages?_format=json&iso3=' + that.silCode + '&page=1&limit=10';
		that.httpsGet(url, function(languages) {
			if (languages && languages._embedded && languages._embedded.mediaLanguages) {
				var language = languages._embedded.mediaLanguages;
				for (var prop in language) {
					//console.log(language[prop]);
					languageId = language[prop].languageId;
				}
			}
			callback(languageId);			
		});
	}
	function getMediaAvailable(langId, callback) {
		var idMap = {};
		var url = 'https://api.arclight.org/v2/media-components?limit=10&subTypes=featureFilm&languageIds=' + langId + 
						'&metadataLanguageTags=en';
		that.httpsGet(url, function(components) {
			var component = components._embedded.mediaComponents;
			for (var prop in component) {
				var mediaId = component[prop].mediaComponentId;
				idMap[mediaId] = true;
			}
			callback(idMap);
		});
	}
};
JesusFilmAPI.prototype.getMedia = function(videoMetaData, callback) {
	var that = this;
	getDescriptions(videoMetaData, function() {
		getMediaURLs(videoMetaData, function() {
			callback();
		});
	});
	function getDescriptions(videoMetaData, callback) {
		var url = 'https://api.arclight.org/v2/media-components/' + videoMetaData.mediaId + '?metadataLanguageTags=' + that.lang2Code + ',en';
		that.httpsGet(url, function(description) {
			console.log(description);
			videoMetaData.title = description.title;
			videoMetaData.shortDescription = description.shortDescription;
			videoMetaData.longDescription = description.longDescription;
			videoMetaData.lengthInMilliseconds = description.lengthInMilliseconds;
			if (description.imageUrls) {
				videoMetaData.imageHighRes = description.imageUrls.mobileCinematicHigh;
				videoMetaData.imageMedRes = description.imageUrls.mobileCinematicLow;
			}
			callback();
		});		
	}
	function getMediaURLs(videoMetaData, callback) {
		var mediaURL = null;
		var url = 'https://api.arclight.org/v2/media-components/' + videoMetaData.mediaId + '/languages/' + that.languageId + 
					'?platform=' + that.deviceType;
		that.httpsGet(url, function(components) {
			var component = components.streamingUrls;
			//console.log(JSON.stringify(component));
			if (component) {
				var prop;
				if (that.deviceType === 'ios') {
					for (prop in component.m3u8) {
						videoMetaData.mediaURL = component.m3u8[prop].url;
					}
				} else if (that.deviceType === 'android') {
					for (prop in component.http) {
						videoMetaData.mediaURL = component.http[prop].url;
					}
				}
			}
			callback();
		});		
	}
};
JesusFilmAPI.prototype.httpsGet = function(url, callback) {
	var json = {};
    if (window.XMLHttpRequest) {
		var http = new XMLHttpRequest();
		http.onload = function(obj) {
			if (http.status === 200) {
				try {
					json = JSON.parse(http.responseText);
				} catch(err) {
					console.log('Could not parse JSON START', url);
					console.log(http.responseText);
					console.log('Could not parse JSON END', url);
					console.log('ERROR', err);
				}
			} else {
				console.log('ERROR', http.status, http.statusText, url);
			}
			callback(json);
		};
		http.onerror = function(event) {
			console.log('ON ERROR', JSON.stringify(event));
			callback(json);
		};
        http.open("GET", url + '&apiKey=' + this.apiKey);// + '&random=' + Math.random());
        http.send();
    } else {
	    console.log('ERROR: window.XMLHttpRequest is not found.');
	    callback(json);
    }
};

