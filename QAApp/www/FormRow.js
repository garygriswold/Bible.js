/**
* This table is used to define a list of fields in a Row.
*/
"use strict";
function FormRow(tBody, rowIndex, numColumns) {
	this.colspan = numColumns;
	this.formRow = tBody.insertRow(rowIndex);
	this.divArray = [this.colspan];
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
FormRow.prototype.addVersion = function(versions, value) {
	return(this.stdSelectList(4, versions, value));
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
	var div = null;
	while(this.formRow.cells.length <= col) {
		var cell = this.formRow.insertCell();
		cell.setAttribute('class', 'role');
		div = document.createElement('div');
		cell.appendChild(div);
		this.divArray[this.formRow.cells.length -1] = div;
	}
	return(div);
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
FormRow.prototype.stdSelectList = function(col, values, current) {
	var cell = this.addCell(col);
	var input = document.createElement('select');
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
FormRow.prototype.updateSelectList = function(field, values, current) {
	for (var i=field.children.length -1; i>=0; i--) {
		field.removeChild(field.children[i]);
	}
	for (i=0; i<values.length; i++) {
		var option = document.createElement('option');
		option.textContent = values[i];
		if (values[i] === current) {
			option.setAttribute('selected', 'selected');
		}
		input.appendChild(option);
	}
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
	for (var i=0; i<this.divArray.length; i++) {
		TweenMax.from(this.divArray[i], 0.5, {height:0, scaleY:0, margin:0, padding:0});
	}
};
FormRow.prototype.close = function() {
	this.close2(this.formRow);
};
FormRow.prototype.close2 = function(row) {
	var that = this;
	allCheckboxesOff();
	if (row) {
		TweenMax.to(row, 0.4, {padding:0, margin:0});
		for (var i=0; i<this.divArray.length; i++) {
			var div = this.divArray[i];
			var cell = div.parentElement;
			TweenMax.to(cell, 0.4, {padding:0, margin:0});
			if (i > 0) {
				TweenMax.to(div, 0.5, {height:0, scaleY:0, margin:0, padding:0});
			} else {
				TweenMax.to(div, 0.5, {height:0, scaleY:0, margin:0, padding:0, onComplete:function() {
					row.parentElement.removeChild(row);	
				}});				
			}	
		}
	}
};

