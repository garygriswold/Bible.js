/**
* Unit Test Harness for AssetBuilder
*/
"use strict";

var options = { buildChapters: true, buildTableContents: false, buildConcordance: false, buildStyleIndex: false, buildHTML: false };
var builder = new AssetBuilder('test2application', 'WEB', options);
builder.build(assetBuilderSuccessCallback, assetBuilderFailureCallback);

function assetBuilderSuccessCallback() {
	console.log('AssetBuilder Success');
}
function assetBuilderFailureCallback(err) {
	console.log('AssetBuilder Failure ', JSON.stringify(err));
}