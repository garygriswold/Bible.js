/**
* Unit Test Harness for AssetBuilder
*/
"use strict";

var options = { buildChapters: true, buildTableContents: true, buildConcordance: true, buildStyleIndex: true, buildHTML: false };
var builder = new AssetBuilder('test2application', 'WEB', options);
builder.build(function(result) {
	if (result instanceof Error) {
		console.log('AssetBuilder Failure ', JSON.stringify(result));
	} else {
		console.log('AssetBuilder Success');
	}
});
