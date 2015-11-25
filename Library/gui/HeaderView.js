/**
* This class presents the status bar user interface, and responds to all
* user interactions on the status bar.
*/
var HEADER_BUTTON_HEIGHT = 44;
var HEADER_BAR_HEIGHT = 52;
var STATUS_BAR_HEIGHT = 14;

function HeaderView(tableContents) {
	this.statusBarInHeader = (deviceSettings.platform() === 'ios') ? true : false;
	//this.statusBarInHeader = false;

	this.hite = HEADER_BUTTON_HEIGHT;
	this.barHite = (this.statusBarInHeader) ? HEADER_BAR_HEIGHT + STATUS_BAR_HEIGHT : HEADER_BAR_HEIGHT;
	this.cellTopPadding = (this.statusBarInHeader) ? 'padding-top:' + STATUS_BAR_HEIGHT + 'px' : 'padding-top:0px';
	this.tableContents = tableContents;
	this.backgroundCanvas = null;
	this.titleCanvas = null;
	this.titleGraphics = null;
	this.currentReference = null;
	this.rootNode = document.getElementById('statusRoot');
	this.labelCell = document.getElementById('labelCell');
	Object.seal(this);
}
HeaderView.prototype.showView = function() {
	var that = this;

	this.backgroundCanvas = document.createElement('canvas');
	paintBackground(this.backgroundCanvas, this.hite);
	this.rootNode.appendChild(this.backgroundCanvas);

	var menuWidth = setupIconButton('tocCell', drawTOCIcon, this.hite, BIBLE.SHOW_TOC);
	var serhWidth = setupIconButton('searchCell', drawSearchIcon, this.hite, BIBLE.SHOW_SEARCH);
	var quesWidth = setupIconButton('questionsCell', drawQuestionsIcon, this.hite, BIBLE.SHOW_QUESTIONS);
	var settWidth = setupIconButton('settingsCell', drawSettingsIcon, this.hite, BIBLE.SHOW_SETTINGS);
	var avalWidth = window.innerWidth - (menuWidth + serhWidth + quesWidth + settWidth + (6 * 4));// six is fudge factor

	this.titleCanvas = document.createElement('canvas');
	drawTitleField(this.titleCanvas, this.hite, avalWidth);
	this.labelCell.appendChild(this.titleCanvas);

	window.addEventListener('resize', function(event) {
		paintBackground(that.backgroundCanvas, that.hite);
		drawTitleField(that.titleCanvas, that.hite, avalWidth);
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
	function drawTitleField(canvas, hite, avalWidth) {
		canvas.setAttribute('id', 'titleCanvas');
		canvas.setAttribute('height', hite);
		canvas.setAttribute('width', avalWidth);
		canvas.setAttribute('style', that.cellTopPadding);
		that.titleGraphics = canvas.getContext('2d');
		that.titleGraphics.fillStyle = '#000000';
		that.titleGraphics.font = '24pt sans-serif';
		that.titleGraphics.textAlign = 'center';
		that.titleGraphics.textBaseline = 'middle';
		that.drawTitle();

		that.titleCanvas.addEventListener('click', function(event) {
			event.stopImmediatePropagation();
			if (that.currentReference) {
				document.body.dispatchEvent(new CustomEvent(BIBLE.SHOW_PASSAGE, { detail: { id: that.currentReference.nodeId }}));
			}
		});
	}
	function setupIconButton(parentCell, canvasFunction, hite, eventType) {
		var canvas = canvasFunction(hite, '#F7F7BB');
		canvas.setAttribute('style', that.cellTopPadding);
		var parent = document.getElementById(parentCell);
		parent.appendChild(canvas);
		canvas.addEventListener('click', function(event) {
			event.stopImmediatePropagation();
			console.log('clicked', parentCell);
			document.body.dispatchEvent(new CustomEvent(eventType));
		});
		return(canvas.width);
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

