/**
*
*/
"use strict";
function RoleForms(currentState, tBody, rowIndex, numColumns) {
	this.colspan = numColumns;
	this.state = currentState;
	this.formRow = new FormRow(tBody, rowIndex, numColumns);
}
RoleForms.prototype.register = function() {
	
};
RoleForms.prototype.name = function(teacherId) {
	var that = this;
	var teacher = this.state.getTeacher(teacherId);
	var nameField = this.formRow.addName(teacher.fullname.textContent);
	var pseudoField = this.formRow.addPseudo(teacher.pseudonym.textContent);
	this.formRow.addButtons(function() {
		// submit to server, on 200 update model
		teacher.fullname.textContent = nameField.value;
		teacher.pseudonym.textContent = pseudoField.value;
		that.formRow.close();
	});
	this.formRow.open();
};
RoleForms.prototype.passPhrase = function(teacherId) {
	var that = this;
	var teacher = this.state.getTeacher(teacherId);
	// Add Explaination to leading columns
	// Add button Go to 
	// Add button Cancel
	// Generate a new passphrase
	
	// Display response passPhrase, where explanation
	// Develop and test with server
};
RoleForms.prototype.replace = function(teacherId) {
	// Combines passPhrase and name
};
RoleForms.prototype.promote = function(teacherId) {
	// Add Explaination to leading columns
	// Add button Go
	// Add button Cancel
	// Change the members authorizer
	
	// Result should delete the row from my own people
	
};
RoleForms.prototype.demote = function(teacherId) {
	// Present pulldown of all names under me, who have at least principal status and the correct versions
	// Add Go button
	// Add Cancel button
	// Change the members authorizer
	
	// Result should delete the row from my own members
};
RoleForms.prototype.addRole = function(teacherId) {
	var that = this;
	var positions = this.state.positionsCanManage();
	var positionsField = this.formRow.addPosition(positions, 'teacher');
	var versions = Object.keys(this.state.principal);
	var versionsField = this.formRow.addVersion(versions);
	if (positions.length > 1) {
		positionsField.addEventListener('change', function() {
			console.log('position select list change event', event.target.selected);
			var currPos = event.target.selected;
			if (currPos === 'teacher') {
				this.formRow.updateSelectList(positionsField, positions);
			} else {
				this.formRow.updateSelectList(positionsField, [])
			}
		});
	}
	this.formRow.addButtons(function() {
		// submit to server if 201 do the following
		var position = positionsField.selected;
		var versionId = versionsField.selected;
		var created = new Date().toString();
		that.state.addRole(teacherId, position, versionId, created);
		that.formRow.close();
	});
	this.formRow.open();
};
RoleForms.prototype.removeRole = function(teacherId, position, versionId) {
	var that = this;
	this.formRow.addButtons(function() {
		//submit to server if 200 do the following
		that.state.removeRole(teacherId, position, versionId);
		that.formRow.close();
	});
	this.formRow.open();
};
