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
    	//if (false) {
    		console.log('error found after open', error);
    		callback(error);
    	} else {
    		console.log('going to do select');
    		database.get('select code, lastChapter from tableContents', [], function(row) {
    			console.log('return from get');
    			if (row instanceof IOEror) {
    			//	if (false) {
    				callback(row);
    			} else {
    				console.log('Found Row' + JSON.stringify(row));
    				callback();
    			}
    		})
    	}
    });
}
exports.pageLoaded = pageLoaded;
