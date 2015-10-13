/**
*
*/
"use strict";
function RoleForms(currentState, tBody, rowIndex) {
	this.colspan = 7;
	this.state = currentState;
	this.formRow = new FormRow(tBody, rowIndex);
}
RoleForms.prototype.register = function() {
	
};
RoleForms.prototype.name = function(teacherId) {
	var that = this;
	var teacher = this.state.teachers[teacherId];
	var nameField = this.formRow.addName(teacher.fullname.textContent);
	var pseudoField = this.formRow.addPseudo(teacher.pseudonym.textContent);
	this.formRow.addButtons(function() {
		// submit to server, on 200 update model
		//var newFullname = nameField.value;
		//var newPseudo = pseudoField.value;
		
		teacher.fullname.textContent = nameField.value;
		teacher.pseudonym.textContent = pseudoField.value;
		that.formRow.close();
	});
	this.formRow.open();
};
RoleForms.prototype.passPhrase = function(teacherId) {
	
};
RoleForms.prototype.replace = function(teacherId) {
	
};
RoleForms.prototype.promote = function(teacherId) {
	
};
RoleForms.prototype.demote = function(teacherId) {
	
};
RoleForms.prototype.addRole = function(teacherId) {
	var that = this;
	var positions = this.state.positionsCanManage();
	console.log('POSITIONS', (typeof positions), positions.length);
	var positionList = this.formRow.addSelectList(3, 'pos_input', positions, 'teacher');
	if (positions.length > 1) {
		positionList.addEventListener('change', function() {
			console.log('position select list change event');
			
		});
	} else {
		addVersion(positions[0]);
	}
	
	function addVersion(position) {
		
	}
};
RoleForms.prototype.removeRole = function(teacherId, versionId, position) {
	
};
