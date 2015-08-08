var IOError = require('./io/IOError');
var DeviceDatabase = require("./io/DeviceDatabase");

var observableModule = require("data/observable");
var source = new observableModule.Observable();

function pageLoaded(args) {
    var page = args.object;
    page.bindingContext = source;

    source.set("oneChapter", "Text set via binding");

    console.log('going to instantiate database');
    var database = new DeviceDatabase('WEB.word1');
    database.open(function(error) {
    	console.log('returned from open');
    	if (error instanceof IOError) {
    		console.log('error found after open', error);
    		callback(error);
    	} else {
    		console.log('going to do select');
            database.chapters.getChapters(['JHN:0', 'JHN:1', 'JHN:2', 'JHN:3', 'JHN:4'], function(results) {
                console.log('back from select');
                if (results instanceof IOError) {
                    console.log('Error found ' + results.message);
                    callback(results);
                } else {
                    for (var i=0; i<results.length; i++) {
                        var row = results[i];
                        console.log(row[0]);
                    }
                    var content = '<div>' + results[3][1] + '</div>';
                    source.set("oneChapter", content);
                    console.log('******* |' + source.oneChapter + '| *******');
                    callback();
                }
            });
    	}
    });
}

exports.pageLoaded = pageLoaded;
