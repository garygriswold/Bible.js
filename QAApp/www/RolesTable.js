/**
* This class maintains the display table of persons and roles.  It is filled
* with selected data, and updated by user interaction.
*/
"use strict";
function RolesTable(currentState, numColumns) {
	this.state = currentState;
	this.numColumns = numColumns;
	this.tBody = null;
	this.buttonRow = null;
}
RolesTable.prototype.insertRow = function(index, type, teacherId, fullname, pseudonym, position, versionId, created) {
	var newRow = this.addTableRow(index);
	var firstRow = this.state.getTeacher(teacherId);
	if (firstRow) {
		var rowCount = Number(firstRow.row.cells[0].getAttribute('rowspan')) + 1;
		for (var i=0; i<3; i++) {
			firstRow.row.cells[i].setAttribute('rowspan', rowCount);
		}
	} else {
		var check1 = this.addTableCell(newRow);
		if (type === 'memb') {
			this.addCheckbox(check1, teacherId);
		}
		var nameCell = this.addTableCell(newRow, fullname);
		var pseudoCell = this.addTableCell(newRow, pseudonym);
		this.state.addTeacher(teacherId, nameCell, pseudoCell, newRow);
	}
	if (type === 'boss') {
		this.addTableCell(newRow, 'director');
		var blank = this.addTableCell(newRow);
		blank.setAttribute('colspan', 4);
	} else {
		var positionCell = this.addTableCell(newRow, position);
		var versionCell = this.addTableCell(newRow, versionId);
		var createdCell = this.addTableCell(newRow, created);
		var check2 = this.addTableCell(newRow);
		this.addCheckbox(check2, teacherId, position, versionId);
		this.state.addRole(teacherId, positionCell, versionCell, createdCell, newRow);
	}
};
RolesTable.prototype.updatePerson = function(teacherId, name, pseudo) {
	// lookup person in teachers
	// update name, and pseudo	
};
RolesTable.prototype.updateRole = function(teacherId, position, version) {
	// lookup teacherId, increment the colspans
	// get the row id
	// insert the position in the very next row.	
};
RolesTable.prototype.deleteRole = function(teacherId, position, version) {
	// lookup role in roles
	// lookup in teacherId
	// decrement the 0, 1, 2 columns
	// remove the role
	// What prevents deleting the last role.
};




RolesTable.prototype.addTableRow = function(index) {
	if (this.tBody === null) {
		this.tBody = document.getElementById('rolesBody');
	}
	var row = this.tBody.insertRow(index); // -1 index inserts at end
	row.setAttribute('class', 'role');
	return(row);	
};
RolesTable.prototype.addTableCell = function(row, content) {
	var cell = row.insertCell();
	cell.setAttribute('class', 'role');
	cell.setAttribute('rowspan', 1);
	if (content) {
		cell.textContent = content;
	}
	return(cell);
};
RolesTable.prototype.addCheckbox = function(cell, teacherId, position, versionId) {
	var that = this;
	var input = document.createElement('input');
	var id = (position && versionId) ? teacherId + '.' + position + '.' + versionId : teacherId;
	input.setAttribute('id', id);
	input.setAttribute('type', 'checkbox');
	input.setAttribute('class', 'role');
	cell.appendChild(input);
	input.addEventListener('change', function(event) {
		console.log('CHECKBOX CHANGE EVENT CAUGHT', event.target.checked);
		if (event.target.checked) {
			if (that.buttonRow === null) { // only turn button if none others are on
				var tableRow = this.parentElement.parentElement;
				console.log('ROW', tableRow.nodeName);
				var parts = this.id.split('.');
				var clickedTeacherId = parts[0];
				var clickedPosition = (parts.length > 1) ? parts[1] : null;
				var clickedVersionId = (parts.length > 2) ? parts[2] : null;
				console.log('clicked', clickedTeacherId, clickedPosition, clickedVersionId);
				if (clickedVersionId) {
					that.displayVersionUpdateButtons(tableRow, clickedTeacherId, clickedPosition, clickedVersionId);
				} else {
					that.displayPersonUpdateButtons(tableRow, clickedTeacherId);
				}
			} else {
				event.target.checked = false;//don't turn on, because another button is on
			}
		} else {
			that.closeButtonRow();
		}
	});
	return(input);
};
RolesTable.prototype.closeButtonRow = function() {
	if (this.buttonRow) {
		this.buttonRow.close();
		this.buttonRow = null;
	}	
};
RolesTable.prototype.allCheckboxesOff = function() {
	for (var i=0; i<this.tBody.rows.length; i++) {
		var row = this.tBody.rows[i];
		turnOffCheckbox(row.cells[0]);
		turnOffCheckbox(row.cells[row.cells.length -1])	
	}
	
	function turnOffCheckbox(cell) {
		if (cell.children && cell.children.length > 0 && cell.firstChild.nodeName === 'INPUT' && cell.firstChild.checked) {
			cell.firstChild.checked = false;
		}	 
	}
};
RolesTable.prototype.displayPersonUpdateButtons = function(parent, teacherId) {
	var that = this;
	this.buttonRow = new ButtonRow(parent, this.numColumns);
	this.buttonRow.addButton('Change Name', function(event) {
		var roleForms = that.buttonRow.createRoleForms(that.state);
		that.closeButtonRow();
		roleForms.name(teacherId);
	});
	this.buttonRow.addButton('New Pass Phrase', function(event) {
		console.log('clicked new pass phrase');
	});
	this.buttonRow.addButton('Replace Person', function(event) {
		console.log('clicked replace person');
	});
	// This is only possible for someone who has a boss.
	this.buttonRow.addButton('Promote Person', function(event) {
		console.log('clicked promote person');
	});
	// This is not possible of authorizing person has no principal under them.
	this.buttonRow.addButton('Demote Person', function(event) {
		console.log('clicked demote person');
	});
	this.buttonRow.open();
};
RolesTable.prototype.displayVersionUpdateButtons = function(parent, teacherId, position, versionId) {
	var that = this;
	this.buttonRow = new ButtonRow(parent, this.numColumns);
	this.buttonRow.addButton('Add Role', function(event) {
		console.log('Add Role button click');
		var roleForms = that.buttonRow.createRoleForms(that.state);
		that.closeButtonRow();
		roleForms.addRole(teacherId);
	});
	this.buttonRow.addButton('Remove Role', function(event) {
		console.log('Remove role button click');
		var roleForms = that.buttonRow.createRoleForms(that.state);
		that.closeButtonRow();
		roleForms.removeRole(teacherId, position, versionId);
	});
	this.buttonRow.open();
};
