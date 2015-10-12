/**
* This table is used to define a list of fields in a Row.
*/
function FormRow(tBody, rowIndex) {
	this.colspan = 7;
	//var tBody = row.parentElement;
	//var next = findNextRow(tBody, rowAbove, this.colspan);
	this.formRow = tBody.insertRow(rowIndex);

}
FormRow.prototype.addName = function(name) {
	return(this.stdTextField(1, name));	
};
FormRow.prototype.addPseudo = function(pseudo) {
	return(this.stdTextField(2, pseudo));
};
FormRow.prototype.addPosition = function(positions, value) {
	return(this.stdSelectList(3, positions, value));
};
FormRow.prototype.addVersion = function() {
	return(this.stdSelectList(4));
};
FormRow.prototype.addButtons = function(callback) {
	var that = this;
	var cell = this.addCell(5);
	this.goButton = this.stdButton(cell, 'Go', callback);
	this.cancelButton = this.stdButton(cell, 'Cancel', function() {
		that.close2(that.formRow);
	});
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
	this.close2(this.formRow);
};
FormRow.prototype.close2 = function(row) {
	if (row) {
		//TweenMax.to(this.cell, 0.5, {scaleY:0, opacity:0.2, onComplete:finishRemove});
		row.parentElement.removeChild(row);
	}
};

