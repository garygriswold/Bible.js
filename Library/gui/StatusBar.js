/**
* This class presents the status bar user interface, and responds to all
* user interactions on the status bar.
*/
"use strict";

function StatusBar(hite) {
	this.hite = hite;
	this.titleWidth = window.outerWidth - hite * 3.5;
	this.titleCanvas = null;
	this.titleGraphics = null;
	this.searchField = null;
	this.rootNode = document.getElementById('statusRoot');
	this.labelCell = document.getElementById('labelCell');
	Object.seal(this);
};
StatusBar.prototype.showView = function() {
	var that = this;

	setupBackground(this.hite);
	setupTocButton(this.hite, '#F7F7BB');
	setupHeading(this.hite);
	setupSearchButton(this.hite, '#F7F7BB');
	setupSettingsButton(this.hite, '#F7F7BB');

	function setupBackground(hite) {
    	var canvas = document.createElement('canvas');
    	canvas.setAttribute('height', hite + 7);
    	var maxSize = (window.outHeight > window.outerWidth) ? window.outerHeight : window.outerWidth;
    	canvas.setAttribute('width', maxSize);
    	canvas.setAttribute('style', 'position: absolute; top: 0; z-index: -1');
      	var graphics = canvas.getContext('2d');
      	graphics.rect(0, 0, canvas.width, canvas.height);

      	// create radial gradient
      	var vMidpoint = hite / 2;

      	var gradient = graphics.createRadialGradient(238, vMidpoint, 10, 238, vMidpoint, window.outerHeight - hite);
      	// light blue
      	gradient.addColorStop(0, '#8ED6FF');
      	// dark blue
      	gradient.addColorStop(1, '#004CB3');

      	graphics.fillStyle = gradient;
      	graphics.fill();
      	that.rootNode.appendChild(canvas);
	}
	function setupTocButton(hite, color) {
		var lineThick = hite/7.0;
		var line1Y = lineThick * 1.5;
		var lineXSrt = line1Y;
		var lineXEnd = hite - lineThick;
		var line2Y = lineThick * 2 + line1Y;
		var line3Y = lineThick * 2 + line2Y;

		var canvas = document.createElement('canvas');
		canvas.setAttribute('height', hite);
		canvas.setAttribute('width', hite + lineXSrt * 0.5);
		canvas.setAttribute('style', 'position: fixed; top: 0; left: 0');
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

		document.getElementById('tocCell').appendChild(canvas);

		canvas.addEventListener('click', function(event) {
			event.stopImmediatePropagation();
			console.log('toc button is clicked');
			document.body.dispatchEvent(new CustomEvent(BIBLE.SHOW_TOC));
		});
	}
	function setupHeading(hite) {
		that.titleCanvas = document.createElement('canvas');
		that.titleCanvas.setAttribute('id', 'titleCanvas');
		that.titleCanvas.setAttribute('height', hite);
		that.titleCanvas.setAttribute('width', that.titleWidth);
		that.titleCanvas.setAttribute('style', 'position: fixed; top: 0; left:' + hite * 1.1);

		that.titleGraphics = that.titleCanvas.getContext('2d');
		that.titleGraphics.fillStyle = '#000000';
		that.titleGraphics.font = '24pt sans-serif';
		that.titleGraphics.textAlign = 'center';
		that.titleGraphics.textBaseline = 'middle';
		that.titleGraphics.borderStyle = 'solid';

		that.labelCell.appendChild(that.titleCanvas);
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
		canvas.setAttribute('width', hite + lineThick);
		canvas.setAttribute('style', 'position: fixed; top: 0; right: ' + hite);
		var graphics = canvas.getContext('2d');

		graphics.beginPath();
		graphics.arc(coordX, coordY, radius, 0, Math.PI*2, true);
		graphics.moveTo(edgeX, edgeY);
		graphics.lineTo(edgeX + radius, edgeY + radius);
		graphics.closePath();

		graphics.lineWidth = lineThick;
		graphics.strokeStyle = color;
		graphics.stroke();

		document.getElementById('searchCell').appendChild(canvas);

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
		canvas.setAttribute('style', 'position: fixed; top: 0; right: 0');
		var graphics = canvas.getContext('2d');

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

		document.getElementById('settingsCell').appendChild(canvas);

		canvas.addEventListener('click', function(event) {
			event.stopImmediatePropagation();
			console.log('settings button is clicked');
			document.body.dispatchEvent(new CustomEvent(BIBLE.SHOW_SETTINGS));
		});
	}
};
StatusBar.prototype.setTitle = function(text) {
	this.titleGraphics.clearRect(0, 0, this.titleWidth, this.hite);
	this.titleGraphics.fillText(text, this.titleWidth / 2, this.hite / 2, this.titleWidth);
};
StatusBar.prototype.showSearchField = function() {
	if (! this.searchField) {
		this.searchField = document.createElement('input');
		this.searchField.setAttribute('type', 'text');
		this.searchField.setAttribute('class', 'searchField');
		var yPos = (this.hite - 40) / 2; // The 40 in this calculation is a hack.
		var xPos = (this.hite * 1.2);
		this.searchField.setAttribute('style', 'position: fixed; top: ' + yPos + '; left: ' + xPos);
		var that = this;
		this.searchField.addEventListener('keyup', function(event) {
			if (event.keyCode === 13) {
				document.body.dispatchEvent(new CustomEvent(BIBLE.SEARCH_START, { detail: { search: that.searchField.value }}));

			}
		});
	}
	this.changeLabelCell(this.searchField);
};
StatusBar.prototype.showTitleField = function() {
	this.changeLabelCell(this.titleCanvas);
};
StatusBar.prototype.changeLabelCell = function(node) {
	for (var i=this.labelCell.children.length -1; i>=0; i--) {
		this.labelCell.removeChild(this.labelCell.children[i]);
	}
	this.labelCell.appendChild(node);
};
