/**
* Unit Test Harness for AssetBuilder
*/
"use strict";

var options = { buildTableContents: true, buildConcordance: true, buildStyleIndex: true, buildHTML: false };
var builder = new AssetBuilder('test2application', 'WEB', options);
builder.build();