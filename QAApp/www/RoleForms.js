/**
*
*/
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
	var nameField = this.formRow.addName(teacher.fullname);
	this.formRow.addPseudo(teacher.pseudonym);
	this.formRow.addButtons(goCallback, this.cancelCallback);
	this.formRow.open();
	function goCallback() {
		// This must submit an update to the server
		// on response, it must find the teacherId in the grid
		// and update the grid with the correct data.
		// 1) update teachers
		// 2) update the correct 
		var newFullname = that.formRow.nameField.value;
		var newPseudo = that.formRow.pseudoField.value;
		console.log('UPDATED', newFullname, newPseudo);
		
		var teacher = that.state.teachers[teacherId];
		teacher.fullname = newFullname;
		teacher.pseudonym = newPseudo;
	}
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
RoleForms.prototype.cancelCallback = function() {
	// must unwind the form here, and delete the row	
};