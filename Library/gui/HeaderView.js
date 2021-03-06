/**
* This class presents the status bar user interface, and responds to all
* user interactions on the status bar.
*/
var HEADER_BUTTON_HEIGHT = 32;
var HEADER_BAR_HEIGHT = 40;
var STATUS_BAR_HEIGHT = 18;//14;
var PHONEX_STATUS_BAR_HEIGHT = 36;//26;
var CELL_SPACING = 5;

function HeaderView(tableContents, version, localizeNumber, videoAdapter) {
	this.hite = HEADER_BUTTON_HEIGHT;
	
	if (deviceSettings.platform() == 'ios') {
		if (deviceSettings.model() == 'iPhone X') {
			this.barHite = HEADER_BAR_HEIGHT + PHONEX_STATUS_BAR_HEIGHT;
			this.cellTopPadding = 'padding-top:' + PHONEX_STATUS_BAR_HEIGHT + 'px';
		} else {
			this.barHite = HEADER_BAR_HEIGHT + STATUS_BAR_HEIGHT;
			this.cellTopPadding = 'padding-top:' + STATUS_BAR_HEIGHT + 'px';			
		}
	} else {
		this.barHite = HEADER_BAR_HEIGHT + 5;
		this.cellTopPadding = 'padding-top:5px';			
	}
	this.tableContents = tableContents;
	this.version = version;
	this.localizeNumber = localizeNumber;
	this.videoAdapter = videoAdapter;
	this.titleCanvas = null;
	this.titleGraphics = null;
	this.titleStartX = null;
	this.titleWidth = null;
	this.currentReference = null;
	this.rootNode = document.createElement('table');
	this.rootNode.id = 'statusRoot';
	this.rootNode.setAttribute('style', 'height:' + this.barHite + 'px');
	document.body.appendChild(this.rootNode);
	this.rootRow = document.createElement('tr');
	this.rootNode.appendChild(this.rootRow);
	this.labelCell = document.createElement('td');
	this.labelCell.id = 'labelCell';
	this.audioNode = null;
	this.audioForBook = false;
	document.addEventListener(BIBLE.CHG_HEADING, drawTitleHandler);
	Object.seal(this);
	var that = this;
	
	function drawTitleHandler(event) {
		if (that.titleGraphics == null) return;
		document.removeEventListener(BIBLE.CHG_HEADING, drawTitleHandler);
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
			if (that.audioNode !== null) {
				if (that.version.hasAudioBook(that.currentReference.book)) {
					if (! that.audioForBook) {
						that.audioForBook = true;
						TweenLite.fromTo(that.audioNode , 1.0, {opacity:0}, {opacity:1.0, display:'table-cell'});
					}
				} else {
					if (that.audioForBook) {
						that.audioForBook = false;
						TweenLite.fromTo(that.audioNode , 1.0, {opacity:1.0}, {opacity:0, display:'none'});
					}
				}
			}
		}
		document.addEventListener(BIBLE.CHG_HEADING, drawTitleHandler);
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

	var menuWidth = setupIconImgButton('tocCell', 'img/MenuIcon128.png', that.hite, BIBLE.SHOW_TOC);
	var serhWidth = setupIconImgButton('searchCell', 'img/SearchIcon128.png', that.hite, BIBLE.SHOW_SEARCH);
	that.rootRow.appendChild(that.labelCell);
	
	var audioWidth = setupIconImgButton('audioCell', 'img/SoundIcon128.png', that.hite, BIBLE.SHOW_AUDIO);
	that.audioNode = document.getElementById('audioCell');
	var videoWidth = setupIconImgButton('videoCell', 'img/ScreenIcon128.png', that.hite, BIBLE.SHOW_VIDEO);
	var settWidth = setupIconImgButton('settingsCell', 'img/SettingsIcon128.png', that.hite, BIBLE.SHOW_SETTINGS);
	var avalWidth = (window.innerWidth * 0.88) - (menuWidth + serhWidth + audioWidth + videoWidth + settWidth);
	
	callNative('AudioPlayer', 'findAudioVersion', [that.version.code, that.version.silCode], "S", function(bookIdList) {
		console.log("VERSION: " + that.version.code + "  SIL: " + that.version.silCode + "  BOOKLIST: " + bookIdList);
		that.version.audioBookIdList = bookIdList;
	});
	
	that.titleCanvas = document.createElement('canvas');
	drawTitleField(that.titleCanvas, that.hite, avalWidth);
	that.labelCell.appendChild(that.titleCanvas);

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
				document.dispatchEvent(new CustomEvent(BIBLE.SHOW_PASSAGE, { detail: { id: that.currentReference.nodeId }}));
			}
		});
	}
	function setupIconImgButton(parentCell, iconFilename, hite, eventType) {
		var canvas = document.createElement('img');
		canvas.setAttribute('src', iconFilename);
		canvas.setAttribute('style', that.cellTopPadding);
		canvas.setAttribute('height', hite);
		canvas.setAttribute('width', hite);
		var parent = document.createElement('td');
		parent.id = parentCell;
		that.rootRow.appendChild(parent);
		parent.appendChild(canvas);
		parent.addEventListener('click', function(event) {
			event.stopImmediatePropagation();
			console.log('clicked', parentCell);
			document.dispatchEvent(new CustomEvent(eventType, { detail: { id: that.currentReference.nodeId }}));
		});
		return(canvas.width);
	}
};
