/**
* This object is able to rewrite HTML pages for the purpose of using the webproxy server.
* 1. rewrite <a href="(.*)"
* 2. rewrite <link href="(.*)"
* 3. rewrite <img src="(.*)"
* 4. rewrite <script src="(.*)"
* 5. recognize http vs https requests
* 6. recognize path only URLs and regularize to full URLs
*/
"use strict";
const PROXY = 'https://mrf2p6k5ud.execute-api.us-west-2.amazonaws.com/latest/web?url=';
const regExp = /(<a|<link|<img|<script)( .*?)(href|src)(=["'])(.*?)(["'].*?>)/g;

var pageRewriter = function(page, hostname, path) {
	page = page.replace(regExp, replaceMatch);
	return(page);

	function replaceMatch(match, p1, p2, p3, p4, p5, p6) {
		if (p5.length > 5 && p5.substr(0,4) === 'http') {
			var result = p1 + p2 + p3 + p4 + PROXY + p5 + p6;
		} else if (p5.length > 2 && p5[0] === '/' && p5[1] === '#') {
			result = p1 + p2 + p3 + p4 + hostname + p5 + p6;
		} else if (p5.length > 0 && p5[0] === '#') {
			result = p1 + p2 + p3 + p4 + hostname + path + p5 + p6;
		} else if (p5.length > 1 && p5[0] === '/') {
			result = p1 + p2 + p3 + p4 + PROXY + hostname + p5 + p6;
		} else {
			result = p1 + p2 + p3 + p4 + PROXY + hostname + path + p5 + p6;
		}
		//console.log(match, '  ', result);
		return(result);
	}
}

module.exports = pageRewriter;


/**
* Unit Test of pageRewriter
*/
/*
const fs = require('fs');
var pageIn = fs.readFileSync('testPageIn.html', {encoding:'UTF-8'});
var pageOut = pageRewriter(pageIn, 'http://www.google.com', '/');
fs.writeFileSync('testPageOut.html', pageOut, {encoding: 'UTF-8'});
*/
