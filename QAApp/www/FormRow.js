/**
* This table is used to define a list of fields in a Row.
*/
function FormRow(tBody, rowIndex) {
	// Possibly this should be replaced by using the row that
	// was left behind by the buttons.
	// But if not, this will work
	this.colspan = 7;
	//var tBody = row.parentElement;
	//var next = findNextRow(tBody, rowAbove, this.colspan);
	this.formRow = tBody.insertRow(rowIndex);
	
//	var msgRow = tBody.insertRow(rowIndex + 1);
//	this.msgCell = msgRow.insertCell();
//	this.msgCell.setAttribute('class', 'role');
	
	this.nameField = null;
	this.pseudoField = null;
	this.positionField = null;
	this.versionField = null;
	this.goButton = null;
	this.cancelButton = null;
}
FormRow.prototype.addName = function(value) {
	this.nameField = this.stdTextField(1, value);	
};
FormRow.prototype.addPseudo = function(value) {
	this.pseudoField = this.stdTextField(2, value);
};
FormRow.prototype.addPosition = function(positions, value) {
	this.positionField = this.stdSelectList(3, positions, value);
};
FormRow.prototype.addVersion = function() {
	this.versionField = this.stdSelectList(4);
};
FormRow.prototype.addButtons = function(goCallback, cancelCallback) {
	var cell = this.addCell(5);
	this.goButton = this.stdButton(cell, 'Go', goCallback);
	this.cancelButton = this.stdButton(cell, 'Cancel', cancelCallback);
};
FormRow.prototype.addCell = function(col) {
	var cell = null;
	while(this.formRow.cells.length <= col) {
		cell = this.formRow.insertCell();
		cell.setAttribute('class', 'role');
	}
	return(cell);
};
FormRow.prototype.stdTextField = function(col, value) {
	var cell = this.addCell(col);
	var input = document.createElement('input');
	input.setAttribute('type', 'text');
	input.setAttribute('class', 'role');
	input.setAttribute('value', value);
	cell.appendChild(input);
	return(input);
};
FormRow.prototype.stdSelectList = function(col, id, values, current) {
	var cell = this.addCell(col);
	var input = document.createElement('select');
	input.setAttribute('id', id);
	input.setAttribute('class', 'role');
	for (var i=0; i<values.length; i++) {
		var option = document.createElement('option');
		option.textContent = values[i];
		if (values[i] === current) {
			option.setAttribute('selected', 'selected');
		}
		input.appendChild(option);
	}
	cell.appendChild(input);
	return(input);
};
FormRow.prototype.stdButton = function(cell, label, callback) {
	var button = document.createElement('button');
	button.setAttribute('class', 'button bigrounded blue');
	button.setAttribute('style', 'margin: 10px 30px 10px 30px');
	button.textContent = label;
	cell.appendChild(button);
	button.addEventListener('click', callback);
	return(button);
};
FormRow.prototype.open = function() {
	this.addCell(6);
	// Animate the from 0 to open the row	
};
FormRow.prototype.close = function() {
	if (this.row) {
		//TweenMax.to(this.cell, 0.5, {scaleY:0, opacity:0.2, onComplete:finishRemove});
		this.row.parentElement.removeChild(this.row);
	}
};