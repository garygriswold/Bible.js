/**
* This class is the UI for the controls in the settings page.
* It also uses the VersionsView to display versions on the settings page.
*/
function SettingsView() {
	this.root = null;
	this.rootNode = document.getElementById('settingRoot');
	this.dom = new DOMBuilder();
	Object.seal(this);
}
SettingsView.prototype.showView = function() {
	console.log('INSIDE SETTINGS SHOW');
	if (! this.root) {
		this.root = this.buildSettingsView();
	}
	if (this.rootNode.children.length < 1) {
		console.log('appending settings node');
		this.rootNode.appendChild(this.root);
	}
};
SettingsView.prototype.hideView = function() {
	for (var i=0; i<this.rootNode.children.length; i++) {
		var node = this.rootNode.children[i];
		if (node === this.node) {
			this.rootNode.removeChild(this.root);
		}
	}
};
SettingsView.prototype.buildSettingsView = function() {
	console.log('INSIDE BUILD');
	var table = document.createElement('table');
	table.id = 'settingsTable';
	//table.setAttribute('id', 'settingsTable');
	
	var textRow = this.dom.addNode(table, 'tr');
	
	// Need to access text from the Bible
	var textCell = this.dom.addNode(textRow, 'td', null, 'For God so Loved the world', 'sampleText');
	textCell.setAttribute('colspan', 3);
	
	var sizeRow = this.dom.addNode(table, 'tr');
	
	var sizeCell = this.dom.addNode(sizeRow, 'td', null, null, 'fontSizeControl');
	sizeCell.setAttribute('colspan', 3);
	var sizeSlider = this.dom.addNode(sizeCell, 'div', null, null, 'fontSizeSlider');
	var sizeThumb = this.dom.addNode(sizeCell, 'div', null, null, 'fontSizeThumb');
	
	var colorRow = this.dom.addNode(table, 'tr');
	var blackCell = this.dom.addNode(colorRow, 'td', 'tableLeftCell', 'For God so Loved', 'blackBackground');
	var colorCtrlCell = this.dom.addNode(colorRow, 'td', 'tableCtrlCol');
	var colorSlider = this.dom.addNode(colorCtrlCell, 'div', null, null, 'fontColorSlider');
	var colorThumb = this.dom.addNode(colorSlider, 'div', null, null, 'fontColorThumb');
	var whiteCell = this.dom.addNode(colorRow, 'td', 'tableRightCell', 'For God so Loved', 'whileBackground');
	
	console.log('RETURN TABLE');
	return(table);
	
};
