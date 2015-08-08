var vmModule = require("./main-view-model");
var IOError = require('./io/IOError');
var DeviceDatabase = require("./io/DeviceDatabase");

function pageLoaded(args) {
    var page = args.object;
    page.bindingContext = vmModule.mainViewModel;

    console.log('going to instantiate database');
    var database = new DeviceDatabase('WEB.word1');
    database.open(function(error) {
    	console.log('returned from open');
    	if (error instanceof IOError) {
    		console.log('error found after open', error);
    		callback(error);
    	} else {
    		console.log('going to do select');
            database.chapters.getChapters(['JHN:1', 'JHN:2', 'JHN:3', 'JHN:4'], function(results) {
                console.log('back from select');
                if (results instanceof IOError) {
                    console.log('Error found ' + results.message);
                    callback(results);
                } else {
                    for (var i=0; i<results.length; i++) {
                        var row = results[i];
                        console.log(row['reference'], row['html']);
                    }
                    callback(results);
                }
            });
    	}
    });
}
exports.pageLoaded = pageLoaded;
