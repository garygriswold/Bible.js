/**
* This class presents the status bar user interface, and responds to all
* user interactions on the status bar.
*/
var HEADER_BUTTON_HEIGHT = 32;//44;
var HEADER_BAR_HEIGHT = 40;//52;
var STATUS_BAR_HEIGHT = 14;

function HeaderView(tableContents, version, localizeNumber, videoAdapter) {
	this.statusBarInHeader = (deviceSettings.platform() === 'ios') ? true : false;
	//this.statusBarInHeader = false;

	this.hite = HEADER_BUTTON_HEIGHT;
	this.barHite = (this.statusBarInHeader) ? HEADER_BAR_HEIGHT + STATUS_BAR_HEIGHT : HEADER_BAR_HEIGHT;
	this.cellTopPadding = (this.statusBarInHeader) ? 'padding-top:' + STATUS_BAR_HEIGHT + 'px' : 'padding-top:0px';
	this.tableContents = tableContents;
	this.version = version;
	this.localizeNumber = localizeNumber;
	this.videoAdapter = videoAdapter;
	this.backgroundCanvas = null;
	this.titleCanvas = null;
	this.titleGraphics = null;
	this.titleStartX = null;
	this.titleWidth = null;
	this.currentReference = null;
	this.rootNode = document.createElement('table');
	this.rootNode.id = 'statusRoot';
	document.body.appendChild(this.rootNode);
	this.rootRow = document.createElement('tr');
	this.rootNode.appendChild(this.rootRow);
	this.labelCell = document.createElement('td');
	this.labelCell.id = 'labelCell';
	document.body.addEventListener(BIBLE.CHG_HEADING, drawTitleHandler);
	Object.seal(this);
	var that = this;
	
	function drawTitleHandler(event) {
		if (that.titleGraphics == null) return;
		document.body.removeEventListener(BIBLE.CHG_HEADING, drawTitleHandler);
		console.log('caught set title event', JSON.stringify(event.detail.reference.nodeId));
		that.currentReference = event.detail.reference;
		
		if (that.currentReference) {
			var book = that.tableContents.find(that.currentReference.book);
			if (book) {
				var text = book.heading + ' ' + that.localizeNumber.toHistLocal(that.currentReference.chapter);
				that.titleGraphics.clearRect(0, 0, that.titleCanvas.width, that.hite);
				that.titleGraphics.fillText(text, that.titleCanvas.width / 2, that.hite / 2, that.titleCanvas.width);
				that.titleWidth = that.titleGraphics.measureText(text).width + 10;
				that.titleStartX = (that.titleCanvas.width - that.titleWidth) / 2;
				roundedRect(that.titleGraphics, that.titleStartX, 0, that.titleWidth, that.hite, 7);
			}
		}
		document.body.addEventListener(BIBLE.CHG_HEADING, drawTitleHandler);
	}
	function roundedRect(ctx, x, y, width, height, radius) {
	  ctx.beginPath();
	  ctx.moveTo(x,y+radius);
	  ctx.lineTo(x,y+height-radius);
	  ctx.arcTo(x,y+height,x+radius,y+height,radius);
	  ctx.lineTo(x+width-radius,y+height);
	  ctx.arcTo(x+width,y+height,x+width,y+height-radius,radius);
	  ctx.lineTo(x+width,y+radius);
	  ctx.arcTo(x+width,y,x+width-radius,y,radius);
	  ctx.lineTo(x+radius,y);
	  ctx.arcTo(x,y,x,y+radius,radius);
	  ctx.stroke();
	}
}
HeaderView.prototype.showView = function() {
	var that = this;
	this.backgroundCanvas = document.createElement('canvas');
	paintBackground(this.backgroundCanvas, this.hite);
	this.rootRow.appendChild(this.backgroundCanvas);

	this.videoAdapter.hasVideos(this.version.langCode, this.version.langPrefCode, function(videoCount) {
		var menuWidth = setupIconButton('tocCell', drawTOCIcon, that.hite, BIBLE.SHOW_TOC);
		var serhWidth = setupIconButton('searchCell', drawSearchIcon, that.hite, BIBLE.SHOW_SEARCH);
		that.rootRow.appendChild(that.labelCell);
		if (videoCount > 0) {
			var videoWidth = setupIconButton('videoCell', drawVideoIcon, that.hite, BIBLE.SHOW_VIDEO);
		} else {
			videoWidth = 0;
		}
		if (that.version.isQaActive == 'T') {
			var quesWidth = setupIconButton('questionsCell', drawQuestionsIcon, that.hite, BIBLE.SHOW_QUESTIONS);
		} else {
			quesWidth = 0;
		}
		var settWidth = setupIconButton('settingsCell', drawSettingsIcon, that.hite, BIBLE.SHOW_SETTINGS);
		var avalWidth = window.innerWidth - (menuWidth + serhWidth + videoWidth + quesWidth + settWidth + (6 * 4));// six is fudge factor
	
		that.titleCanvas = document.createElement('canvas');
		drawTitleField(that.titleCanvas, that.hite, avalWidth);
		that.labelCell.appendChild(that.titleCanvas);
	});

	function paintBackground(canvas, hite) {
		console.log('**** repaint background ****');
    	canvas.setAttribute('height', that.barHite);
    	canvas.setAttribute('width', window.innerWidth);// outerWidth is zero on iOS
    	canvas.setAttribute('style', 'position: absolute; top:0; left:0; z-index: -1');
      	var graphics = canvas.getContext('2d');
      	graphics.rect(0, 0, canvas.width, canvas.height);

      	// create radial gradient
      	var vMidpoint = hite / 2;
      	var gradient = graphics.createRadialGradient(238, vMidpoint, 10, 238, vMidpoint, window.innerHeight - hite);
      	// light blue
      	gradient.addColorStop(0, '#2E9EC9');//'#8ED6FF');
      	// dark blue
      	gradient.addColorStop(1, '#2E9EC9');//'#004CB3');

      	graphics.fillStyle = '#2E9EC9';//gradient; THE GRADIENT IS NOT BEING USED.
      	graphics.fill();
	}
	function drawTitleField(canvas, hite, avalWidth) {
		canvas.setAttribute('id', 'titleCanvas');
		canvas.setAttribute('height', hite);
		canvas.setAttribute('width', avalWidth);
		canvas.setAttribute('style', that.cellTopPadding);
		that.titleGraphics = canvas.getContext('2d');
		
		that.titleGraphics.fillStyle = '#1b2f76';
		that.titleGraphics.font = '18pt sans-serif';
		that.titleGraphics.textAlign = 'center';
		that.titleGraphics.textBaseline = 'middle';
		that.titleGraphics.strokeStyle = '#1b2f76';
		that.titleGraphics.lineWidth = 0.5;

		that.titleCanvas.addEventListener('click', function(event) {
			event.stopImmediatePropagation();
			if (that.currentReference && event.offsetX > that.titleStartX && event.offsetX < (that.titleStartX + that.titleWidth)) {
				document.body.dispatchEvent(new CustomEvent(BIBLE.SHOW_PASSAGE, { detail: { id: that.currentReference.nodeId }}));
			}
		});
	}
	function setupIconButton(parentCell, canvasFunction, hite, eventType) {
		var canvas = canvasFunction(hite, '#F7F7BB');
		canvas.setAttribute('style', that.cellTopPadding);
		var parent = document.createElement('td');
		parent.id = parentCell;
		that.rootRow.appendChild(parent);
		parent.appendChild(canvas);
		canvas.addEventListener('click', function(event) {
			event.stopImmediatePropagation();
			console.log('clicked', parentCell);
			document.body.dispatchEvent(new CustomEvent(eventType));
		});
		return(canvas.width);
	}
};

