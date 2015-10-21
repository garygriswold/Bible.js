/**
* This table is used to define a list of fields in a Row.
*/
"use strict";
function FormRow(tBody, rowIndex) {
	this.formRow = tBody.insertRow(rowIndex);
	this.nameField = null;
	this.pseudoField = null;
	this.divArray = [];
}
FormRow.prototype.addBlank = function(pos, colspan) {
	this.addCell(pos, colspan);	
};
FormRow.prototype.addName = function(name) {
	this.nameField = this.stdTextField(name);
	return(this.nameField);
};
FormRow.prototype.addPseudo = function(pseudo) {
	this.pseudoField = this.stdTextField(pseudo);
	return(this.pseudoField);
};
FormRow.prototype.addPosition = function(positions, value) {
	return(this.stdSelectList(positions, value));
};
FormRow.prototype.addVersion = function(versions, value) {
	return(this.stdSelectList(versions, value));
};
FormRow.prototype.addQualified = function(qualified) {
	return(this.stdSelectList(qualified));
};
FormRow.prototype.addButtons = function(callback) {
	var that = this;
	var cell = this.addCell(2);
	this.goButton = this.stdButton(cell, 'Do It', callback);
	this.cancelButton = this.stdButton(cell, 'Cancel', function() {
		that.close2(that.formRow);
	});
};
FormRow.prototype.setDoneButton = function(pos) {
	var that = this;
	var cell5 = this.divArray[pos];
	for (var i=cell5.children.length -1; i>=0; i--) {
		cell5.removeChild(cell5.children[i]);
	}
	this.stdButton(cell5, 'Done', function() {
		that.close2(that.formRow);
	});
};
FormRow.prototype.addMessage = function(colspan, message) {
	var cell = this.addCell(colspan);
	cell.textContent = message;
};
FormRow.prototype.setMessage = function(col, message1, message2) {
	var div = this.divArray[col];
	div.textContent = message1;
	if (message2) {
		div.appendChild(document.createElement('br'));
		div.appendChild(document.createTextNode(message2));
	}
};
FormRow.prototype.addCell = function(colspan) {
	var cell = this.formRow.insertCell();
	cell.setAttribute('class', 'role');
	cell.setAttribute('colspan', colspan);
	var div = document.createElement('div');
	cell.appendChild(div);
	this.divArray.push(div);
	return(div);
};
FormRow.prototype.stdTextField = function(value) {
	var cell = this.addCell(1);
	var input = document.createElement('input');
	input.setAttribute('type', 'text');
	input.setAttribute('class', 'role');
	input.setAttribute('value', value);
	cell.appendChild(input);
	return(input);
};
FormRow.prototype.stdSelectList = function(values, current) {
	var cell = this.addCell(1);
	var input = document.createElement('select');
	input.setAttribute('class', 'role');
	for (var i=0; i<values.length; i++) {
		var option = document.createElement('option');
		if ((typeof values[i]) === 'string') {
			option.textContent = values[i];
		} else {
			option.value = values[i].value;
			option.textContent = values[i].label;
		}
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
		field.appendChild(option);
	}
};
FormRow.prototype.stdButton = function(cell, label, callback) {
	var button = document.createElement('button');
	button.setAttribute('class', 'button bigrounded blue');
	button.setAttribute('style', 'margin: 10px 10px 10px 10px');
	button.textContent = label;
	cell.appendChild(button);
	button.addEventListener('click', callback);
	return(button);
};
FormRow.prototype.validateFields = function() {
	if (this.nameField && (this.nameField.value === null || this.nameField.value.length === 0)) {
		return('You must enter a fullname.');
	}
	if (this.pseudoField && (this.pseudoField.value === null || this.pseudoField.value.length === 0)) {
		return('You must enter a pseudonym.');
	}
	return(null);
};
FormRow.prototype.open = function() {
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
	if (row && row.parentElement) {
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

