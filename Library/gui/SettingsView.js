/**
* This class is the UI for the controls in the settings page.
* It also uses the VersionsView to display versions on the settings page.
*/
function SettingsView(versesAdapter) {
	this.root = null;
	this.versesAdapter = versesAdapter;
	this.rootNode = document.getElementById('settingRoot');
	this.dom = new DOMBuilder();
	this.versionsView = new VersionsView();
	Object.seal(this);
}
SettingsView.prototype.showView = function() {
	document.body.style.backgroundColor = '#ABC';
	if (! this.root) {
		this.root = this.buildSettingsView();
	}
	if (this.rootNode.children.length < 1) {
		this.rootNode.appendChild(this.root);
	}
	this.startControls();
	this.versionsView.showView();
};
SettingsView.prototype.hideView = function() {
	if (this.rootNode.children.length > 0) {
		// should I save scroll position here
		for (var i=this.rootNode.children.length -1; i>=0; i--) {
			this.rootNode.removeChild(this.rootNode.children[i]);
		}
	}	
};
SettingsView.prototype.buildSettingsView = function() {
	var that = this;
	var table = document.createElement('table');
	table.id = 'settingsTable';
	
	addRowSpace(table);
	var sizeRow = this.dom.addNode(table, 'tr');
	var sizeCell = this.dom.addNode(sizeRow, 'td', null, null, 'fontSizeControl');
	var sizeSlider = this.dom.addNode(sizeCell, 'div', null, null, 'fontSizeSlider');
	var sizeThumb = this.dom.addNode(sizeCell, 'div', null, null, 'fontSizeThumb');
	
	addRowSpace(table);
	var textRow = this.dom.addNode(table, 'tr');
	var textCell = this.dom.addNode(textRow, 'td', null, null, 'sampleText');
	
	/**
	* This is not used because it had a negative impact on codex performance, but keep as an
	* example toggle switch.*/
	/* This is kept in as a hack, because the thumb on fontSizeControl does not start in the correct
	* position, unless this code is here. */
	addRowSpace(table);
	var colorRow = this.dom.addNode(table, 'tr');
	var blackCell = this.dom.addNode(colorRow, 'td', 'tableLeftCol', null, 'blackBackground');
	var colorCtrlCell = this.dom.addNode(colorRow, 'td', 'tableCtrlCol');
	var colorSlider = this.dom.addNode(colorCtrlCell, 'div', null, null, 'fontColorSlider');
	var colorThumb = this.dom.addNode(colorSlider, 'div', null, null, 'fontColorThumb');
	var whiteCell = this.dom.addNode(colorRow, 'td', 'tableRightCol', null, 'whiteBackground');
	
	addRowSpace(table);
	addJohn316(textCell);
	return(table);
	
	function addRowSpace(table) {
		var row = table.insertRow();
		var cell = row.insertCell();
		cell.setAttribute('class', 'rowSpace');
	}
	function addJohn316(verseNode) {
		that.versesAdapter.getVerses(['JHN:3:16'], function(results) {
			if (results instanceof IOError) {
				console.log('Error while getting JHN:3:16');
			} else {
				if (results.rows.length > 0) {
					var row = results.rows.item(0);
					verseNode.textContent = row.html;
				}	
			}
		});

	}
};
SettingsView.prototype.startControls = function() {
	var docFontSize = document.documentElement.style.fontSize;
	startFontSizeControl(docFontSize, 10, 36);
	
	function startFontSizeControl(fontSizePt, ptMin, ptMax) {
		var fontSize = parseFloat(fontSizePt);
	    var sampleNode = document.getElementById('sampleText');
	    var ptRange = ptMax - ptMin;
    	var draggable = Draggable.create('#fontSizeThumb', {type:'x', bounds:'#fontSizeSlider', onDrag:function() {
			resizeText(this.x, this.minX, this.maxX);
    	}});
    	var drag0 = draggable[0];
    	var startX = (fontSize - ptMin) / ptRange * (drag0.maxX - drag0.minX) + drag0.minX;
    	TweenMax.set('#fontSizeThumb', {x:startX});
    	resizeText(startX, drag0.minX, drag0.maxX);

		function resizeText(x, min, max) {
	    	var size = (x - min) / (max - min) * ptRange + ptMin;
			sampleNode.style.fontSize = size + 'pt';
			document.documentElement.style.fontSize = size + 'pt';		    
    	}
    }
    /* This is not used, changing colors had a negative impact on codexView performance. Keep as a toggle switch example.
	function startFontColorControl(state) {
	    var onOffState = state;
	    var sliderNode = document.getElementById('fontColorSlider');
	    var sampleNode = document.getElementById('sampleText');
    	var draggable = Draggable.create('#fontColorThumb', {type:'x', bounds:sliderNode, throwProps:true, snap:function(v) {
	    		var snap = (v - this.minX < (this.maxX - this.minX) / 2) ? this.minX : this.maxX;
	    		var newState = (snap > this.minX);
	    		if (newState != onOffState) {
		    		onOffState = newState;
		    		setColors(onOffState);
	    		}
	    		return(snap);
    		}
    	});
    	var startX = (onOffState) ? draggable[0].maxX : draggable[0].minX;
    	TweenMax.set('#fontColorThumb', {x:startX});
    	setColors(onOffState);
    	
    	function setColors(onOffState) {
	    	var color = (onOffState) ? '#00FF00' : '#FFFFFF';
			TweenMax.to(sliderNode, 0.4, {backgroundColor: color});
			sampleNode.style.backgroundColor = (onOffState) ? '#000000' : '#FFFFFF';
			sampleNode.style.color = (onOffState) ? '#FFFFFF' : '#000000';
    	}
    }*/
};

