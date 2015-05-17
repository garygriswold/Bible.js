/**
* This class presents the status bar user interface, and responds to all
* user interactions on the status bar.
*/
"use strict";

function StatusBar() {
	this.rootNode = document.getElementById('statusRoot');
	var that = this;

	setupBackground(88);
	setupTocButton(88, '#F7F7BB');
	setupHeading(88);
	setupSearchButton(88, '#F7F7BB');
	setupSettingsButton(88, '#F7F7BB');

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
};