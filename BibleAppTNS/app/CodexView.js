var IOError = require('./io/IOError');
var DeviceDatabase = require("./io/DeviceDatabase");

function pageLoaded(args) {
    var page = args.object;
    
    var scrollViewModule = require('ui/scroll-view');
    var scrollView = new scrollViewModule.ScrollView();
    page.content = scrollView;

    var htmlViewModule = require("ui/html-view");
    var htmlView = new htmlViewModule.HtmlView();
    scrollView.content = htmlView;
    iosVersion = htmlView.ios;
    iosVersion.numberOfLines = 0;
    htmlView.html = 'Hello World';

    var database = new DeviceDatabase('WEB.word1');
    database.open(function(error) {
    	if (error instanceof IOError) {
    		console.log('error found after open', error);
    		callback(error);
    	} else {
            database.chapters.getChapters(['JHN:0', 'JHN:1', 'JHN:2', 'JHN:3', 'JHN:4'], function(results) {
                if (results instanceof IOError) {
                    console.log('Error found ' + results.message);
                    callback(results);
                } else {
                    for (var i=0; i<results.length; i++) {
                        var row = results[i];
                        console.log(row[0]);
                    }
                    var content = String(results[3][1]);
                    var sectionEnd = content.indexOf('</section>');
                    content = content.substr(sectionEnd + 10);
                    var content = '<div class="top">' + content + '</div>';
                    htmlView.html = content;
                    console.log('******* |' + content + '| *******');
                    callback();
                }
            });
    	}
    });
}

exports.pageLoaded = pageLoaded;
