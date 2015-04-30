/**
* Unit Test Harness for AssetBuilder
*/
"use strict";

var options = { buildChapters: true, buildTableContents: true, buildConcordance: true, buildStyleIndex: true, buildHTML: false };
var builder = new AssetBuilder('test2application', 'WEB', options);
builder.build(assetBuilderSuccessCallback, assetBuilderFailureCallback);

function assetBuilderSuccessCallback() {
	console.log('AssetBuilder Success');
}
function assetBuilderFailureCallback(err) {
	console.log('AssetBuilder Failure ', JSON.stringify(err));
}