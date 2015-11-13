/**
* This class presents the status bar user interface, and responds to all
* user interactions on the status bar.
*/
var HEADER_BUTTON_HEIGHT = 44;
var HEADER_BAR_HEIGHT = 52;
var STATUS_BAR_HEIGHT = 14;

function HeaderView(tableContents) {
	this.statusBarInHeader = (deviceSettings.platform() === 'ios') ? true : false;
	this.statusBarInHeader = false;

	this.hite = HEADER_BUTTON_HEIGHT;
	this.barHite = (this.statusBarInHeader) ? HEADER_BAR_HEIGHT + STATUS_BAR_HEIGHT : HEADER_BAR_HEIGHT;
	this.cellTopPadding = (this.statusBarInHeader) ? 'padding-top:' + STATUS_BAR_HEIGHT + 'px' : 'padding-top:0px';
	this.tableContents = tableContents;
	this.backgroundCanvas = null;
	this.titleCanvas = null;
	this.titleGraphics = null;
	this.currentReference = null;
	this.searchField = null;
	this.rootNode = document.getElementById('statusRoot');
	this.labelCell = document.getElementById('labelCell');
	Object.seal(this);
}
HeaderView.prototype.showView = function() {
	var that = this;

	this.backgroundCanvas = document.createElement('canvas');
	paintBackground(this.backgroundCanvas, this.hite);
	this.rootNode.appendChild(this.backgroundCanvas);

	setupTocButton(this.hite, '#F7F7BB');
	setupSearchButton(this.hite, '#F7F7BB');
	setupQuestionsButton(this.hite, '#F7F7BB');
	setupSettingsButton(this.hite, '#F7F7BB');

	this.titleCanvas = document.createElement('canvas');
	drawTitleField(this.titleCanvas, this.hite);
	this.labelCell.appendChild(this.titleCanvas);

	window.addEventListener('resize', function(event) {
		paintBackground(that.backgroundCanvas, that.hite);
		drawTitleField(that.titleCanvas, that.hite);
	});

	function paintBackground(canvas, hite) {
    	canvas.setAttribute('height', that.barHite);
    	canvas.setAttribute('width', window.innerWidth);// outerWidth is zero on iOS
    	canvas.setAttribute('style', 'position: absolute; top:0; left:0; z-index: -1');
      	var graphics = canvas.getContext('2d');
      	graphics.rect(0, 0, canvas.width, canvas.height);

      	// create radial gradient
      	var vMidpoint = hite / 2;
      	var gradient = graphics.createRadialGradient(238, vMidpoint, 10, 238, vMidpoint, window.innerHeight - hite);
      	// light blue
      	gradient.addColorStop(0, '#8ED6FF');
      	// dark blue
      	gradient.addColorStop(1, '#004CB3');

      	graphics.fillStyle = gradient;
      	graphics.fill();
	}
	function setupTocButton(hite, color) {
		var canvas = drawTOCIcon(hite, color);
		canvas.setAttribute('style', that.cellTopPadding);
		document.getElementById('tocCell').appendChild(canvas);

		canvas.addEventListener('click', function(event) {
			event.stopImmediatePropagation();
			console.log('toc button is clicked');
			document.body.dispatchEvent(new CustomEvent(BIBLE.SHOW_TOC));
		});
	}
	function drawTitleField(canvas, hite) {
		canvas.setAttribute('id', 'titleCanvas');
		canvas.setAttribute('height', hite);
		canvas.setAttribute('style', that.cellTopPadding);
		that.titleGraphics = canvas.getContext('2d');
		that.titleGraphics.fillStyle = '#000000';
		that.titleGraphics.font = '24pt sans-serif';
		that.titleGraphics.textAlign = 'center';
		that.titleGraphics.textBaseline = 'middle';
		that.titleGraphics.borderStyle = 'solid';
		that.drawTitle();

		that.titleCanvas.addEventListener('click', function(event) {
			if (that.currentReference) {
				document.body.dispatchEvent(new CustomEvent(BIBLE.SHOW_PASSAGE, { detail: { id: that.currentReference.nodeId }}));
			}
		});
	}
	function setupSearchButton(hite, color) {
		var canvas = drawSearchIcon(hite, color);
		canvas.setAttribute('style', that.cellTopPadding);
		document.getElementById('searchCell').appendChild(canvas);

		canvas.addEventListener('click', function(event) {
			event.stopImmediatePropagation();
			console.log('search button is clicked');
			document.body.dispatchEvent(new CustomEvent(BIBLE.SHOW_SEARCH));
		});
	}
	function setupQuestionsButton(hite, color) {
		var canvas = drawQuestionsIcon(hite, color);
		canvas.setAttribute('style', that.cellTopPadding);
		document.getElementById('questionsCell').appendChild(canvas);

		canvas.addEventListener('click', function(event) {
			event.stopImmediatePropagation();
			console.log('questions button is clicked');
			document.body.dispatchEvent(new CustomEvent(BIBLE.SHOW_QUESTIONS));
		});
	}
	function setupSettingsButton(hite, color) {
		var canvas = drawSettingsIcon(hite, color);
		canvas.setAttribute('style', that.cellTopPadding);
		document.getElementById('settingsCell').appendChild(canvas);
		
		canvas.addEventListener('click', function(event) {
			event.stopImmediatePropagation();
			console.log('settings button is clicked');
			document.body.dispatchEvent(new CustomEvent(BIBLE.SHOW_SETTINGS));
		});
	}
};
HeaderView.prototype.setTitle = function(reference) {
	this.currentReference = reference;
	this.drawTitle();
};
HeaderView.prototype.drawTitle = function() {
	if (this.currentReference) {
		var book = this.tableContents.find(this.currentReference.book);
		var text = book.name + ' ' + ((this.currentReference.chapter > 0) ? this.currentReference.chapter : 1);
		this.titleGraphics.clearRect(0, 0, this.titleCanvas.width, this.hite);
		this.titleGraphics.fillText(text, this.titleCanvas.width / 2, this.hite / 2, this.titleCanvas.width);
	}
};
HeaderView.prototype.showSearchField = function(query) {
	if (! this.searchField) {
		this.searchField = document.createElement('input');
		this.searchField.setAttribute('type', 'text');
		this.searchField.setAttribute('class', 'searchField');
		this.searchField.setAttribute('value', query || '');
		var style = [];
		//var style = [ 'position:fixed;' ];
		//style.push('left:' + (this.hite * 1.1) + 'px');
		//style.push('width:' + (window.innerWidth - this.hite * 4.0) + 'px');
		if (this.statusBarInHeader) {
			style.push('height:' + (HEADER_BAR_HEIGHT * 0.5) + 'px');
			style.push('top:' + (HEADER_BAR_HEIGHT * 0.15 + STATUS_BAR_HEIGHT) + 'px');
		} else {
			style.push('height:' + (HEADER_BAR_HEIGHT * 0.65) + 'px');
			style.push('top:' + (HEADER_BAR_HEIGHT * 0.15) + 'px');
		}
		//this.searchField.setAttribute('style', style.join(';'));

		var that = this;
		this.searchField.addEventListener('keyup', function(event) {
			if (event.keyCode === 13) {
				document.body.dispatchEvent(new CustomEvent(BIBLE.SEARCH_START, { detail: { search: that.searchField.value }}));

			}
		});
	}
	this.changeLabelCell(this.searchField);
};
HeaderView.prototype.showTitleField = function() {
	this.changeLabelCell(this.titleCanvas);
};
HeaderView.prototype.changeLabelCell = function(node) {
	for (var i=this.labelCell.children.length -1; i>=0; i--) {
		this.labelCell.removeChild(this.labelCell.children[i]);
	}
	this.labelCell.appendChild(node);
};
