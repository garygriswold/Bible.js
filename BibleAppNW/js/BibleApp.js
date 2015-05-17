/**
* This class presents the status bar user interface, and responds to all
* user interactions on the status bar.
*/
"use strict";

function StatusBar() {
	this.rootNode = document.getElementById('statusRoot');
	this.rootNode.setAttribute('style', 'border-style: solid; border-thickness: 1px;');
	var that = this;
	setupTocButton(100, '#CCCCCC');
	setupHeading(100);
	setupSearchButton(100, '#CCCCCC');
	setupSettingsButton(100, '#CCCCCC');

	function setupTocButton(hite, color) {
		var lineThick = hite/7.0;
		var line1Y = lineThick * 1.5;
		var lineXSrt = line1Y;
		var lineXEnd = hite;
		var line2Y = lineThick * 2 + line1Y;
		var line3Y = lineThick * 2 + line2Y;

		var canvas = document.createElement('canvas');
		canvas.setAttribute('height', hite);
		canvas.setAttribute('width', hite + lineXSrt);
		var graphics = canvas.getContext('2d');
	
		graphics.beginPath();
		graphics.moveTo(lineXSrt, line1Y);
		graphics.lineTo(lineXEnd, line1Y);
		graphics.moveTo(lineXSrt, line2Y);
		graphics.lineTo(lineXEnd, line2Y);
		graphics.moveTo(lineXSrt, line3Y);
		graphics.lineTo(lineXEnd, line3Y);

		graphics.lineWidth = lineThick;
		graphics.lineCap = 'square';
		graphics.strokeStyle = color;
		graphics.stroke();

		document.getElementById('tocRoot').appendChild(canvas);

		canvas.addEventListener('click', function(event) {
			event.stopImmediatePropagation();
			console.log('toc button is clicked');
			document.body.dispatchEvent(new CustomEvent(BIBLE.SHOW_TOC));
		});
	}
	function setupHeading(hite) {
		var text = document.createElement('span');
		text.setAttribute('class', 'statusBar');
		text.textContent = 'Hello World';
		document.getElementById('labelRoot').appendChild(text);

		document.body.addEventListener(BIBLE.CHG_HEADING, function(event) {
			console.log('new heading to be presented');
			text.textContent = event.detail.title;
		});
	}
	function setupSearchButton(hite, color) {
		var lineThick = hite/7.0;
		var radius = (hite / 2) - (lineThick * 1.5);
		var coordX = radius + (lineThick * 1.5);
		var coordY = radius + lineThick * 1.25;
		var edgeX = coordX + radius / 2 + 2;
		var edgeY = coordY + radius / 2 + 2;

		var canvas = document.createElement('canvas');
		canvas.setAttribute('height', hite);
		canvas.setAttribute('width', hite + lineThick * 1.5);
		var graphics = canvas.getContext('2d');

		graphics.beginPath();
		graphics.arc(coordX, coordY, radius, 0, Math.PI*2, true);
		graphics.moveTo(edgeX, edgeY);
		graphics.lineTo(edgeX + radius, edgeY + radius);
		graphics.closePath();

		graphics.lineWidth = lineThick;
		graphics.strokeStyle = color;
		graphics.stroke();

		document.getElementById('searchRoot').appendChild(canvas);

		canvas.addEventListener('click', function(event) {
			event.stopImmediatePropagation();
			console.log('search button is clicked');
			document.body.dispatchEvent(new CustomEvent(BIBLE.SHOW_SEARCH));
		});
	}
	function setupSettingsButton(hite, color) {
		var lineThick = hite/7.0;
		var radius = (hite / 2) - (lineThick * 1.75);
		var coord = hite / 2;
		var circle = Math.PI * 2;
		var increment = Math.PI / 4;
		var first = increment / 2;

		var canvas = document.createElement('canvas');
		canvas.setAttribute('height', hite);
		canvas.setAttribute('width', hite);
		var graphics = canvas.getContext('2d');

		console.log('radius', radius);
		graphics.beginPath();
		graphics.arc(coord, coord, radius, 0, Math.PI*2, true);
		for (var angle=first; angle<circle; angle+=increment) {
			graphics.moveTo(Math.cos(angle) * radius + coord, Math.sin(angle) * radius + coord);
			graphics.lineTo(Math.cos(angle) * radius * 1.6 + coord, Math.sin(angle) * radius * 1.6 + coord);
		}
		graphics.closePath();

		graphics.lineWidth = lineThick;
		graphics.strokeStyle = color;
		graphics.stroke();

		document.getElementById('settingsRoot').appendChild(canvas);

		canvas.addEventListener('click', function(event) {
			event.stopImmediatePropagation();
			console.log('settings button is clicked');
			document.body.dispatchEvent(new CustomEvent(BIBLE.SHOW_SETTINGS));
		});
	}
};/**
* BibleApp is a global object that contains pointers to all of the key elements of
* a user's session with the App.
*/
"use strict"

var BIBLE = { SHOW_TOC: 'bible-show-toc', SHOW_SEARCH: 'bible-show-search', SHOW_SETTINGS: 'bible-show-settings', 
		TOC_FIND: 'bible-toc-find', LOOK: 'bible-look', SEARCH: 'bible-search',
		CHG_HEADING: 'bible-chg-heading', 
		BACK: 'bible-back', FORWARD: 'bible-forward', LAST: 'bible-last', 
		SHOW_NOTE: 'bible-show-note', HIDE_NOTE: 'bible-hide-note' };

function AppViewController(versionCode) {
	this.versionCode = versionCode;
};
AppViewController.prototype.begin = function() {
	var types = new AssetType('document', this.versionCode);
	types.tableContents = true;
	types.chapterFiles = true;
	types.history = true;
	types.concordance = true;
	types.styleIndex = true;
	this.bibleCache = new BibleCache(types);
	var that = this;
	var assets = new AssetController(types);
	assets.checkBuildLoad(function(typesLoaded) {
		that.tableContents = assets.tableContents();
		console.log('loaded toc', that.tableContents.size());
		that.history = assets.history();
		console.log('loaded history', that.history.size());
		that.concordance = assets.concordance();
		console.log('loaded concordance', that.concordance.size());

		that.tableContentsView = new TableContentsView(that.tableContents);
		that.searchView = new SearchView(that.tableContents, that.concordance, that.bibleCache);
		that.codexView = new CodexView(that.tableContents, that.bibleCache);
		Object.freeze(that);

		that.tableContentsView.showView();
		//that.searchView.showView("risen");
	});
};
