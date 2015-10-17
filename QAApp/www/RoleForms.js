/**
*
*/
"use strict";
function RoleForms(rowIndex, table) {
	this.table = table;
	this.state = table.state;
	this.formRow = new FormRow(table.tBody, rowIndex, table.numColumns);
}
RoleForms.prototype.register = function() {
	
};
RoleForms.prototype.name = function(teacher) {
	var that = this;
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
RoleForms.prototype.passPhrase = function(teacher) {
	var that = this;
	var message = 'When you create a new Pass Phrase, the user will not be able to access their account until after they login with their new Pass Phrase.';
	this.formRow.addMessage(1, message);
	this.formRow.addButtons(function() {
		// submit to server, on 200 display passphrase
		message = 'Be sure to give this user their new Pass Phrase, exactly.';
		that.formRow.setMessage(1, message);
		that.formRow.setMessage(2, 'TheirNewPassPhrase');
		that.formRow.setDoneButton();
	});
	this.formRow.open();
};
RoleForms.prototype.replace = function(teacher) {
	var that = this;
	var nameField = this.formRow.addName('');
	var pseudoField = this.formRow.addPseudo('');
	this.formRow.addMessage(3, 'Use this to replace a person with a new person.');
	this.formRow.addButtons(function() {
		// submit to server, on 200 update model
		teacher.fullname.textContent = nameField.value;
		teacher.pseudonym.textContent = pseudoField.value;
		
		var message = 'Be sure to give this user their new Pass Phrase, exactly.';
		that.formRow.setMessage(1, message);
		that.formRow.setMessage(2, 'TheirNewPassPhrase');
		that.formRow.setDoneButton();
	});
	this.formRow.open();
};
RoleForms.prototype.promote = function(teacher) {
	var that = this;
	this.formRow.addMessage(1, 'Use this to move a person out of your authority to the person who authorizes you.');
	this.formRow.addButtons(function() {
		// submit to server, on 200 update model
		that.table.deletePerson(teacher);
		that.formRow.close();
	});
	this.formRow.open();
};
RoleForms.prototype.demote = function(teacher) {
	var that = this;
	this.formRow.addMessage(1, 'Use this to move a person out of your authority to one of your members.');
	// produce a list of all persons under me who are above principle, or who are principal and have
	// all of the versions this person has.
	// There is a problem here.
	// I have no way to easily get all of the roles of this person.
	// This is a problem with the structure of the model
	var persons = [];
	var personsField = this.formRow.addPersons(persons);
	this.formRow.addButtons(function() {
		// submit to server, on 200 do the following
		that.table.deletePerson(teacher);
		that.formRow.close();
	});
	this.formRow.open();
	
	function findQualifiedMembers() {
		var persons = [];
		var teacherKeys = Object.keys(that.state.teachers);
		for (var i=0; i<teacherKeys.length; i++) {
			var teacher = that.state.getTeacher(teacherKeys[i]);
			var position = teacher.position.textContent;
			if (position === 'board' || position === 'director') {
				persons.push({teacherId:teacher.teacherId, fullname:teacher.fullname.textContent});
			} 
			else if (teacher.position.textContent === 'principal') {
				// if the principal has authority for the same languages as the one being demoted
			}
		}
	}
};
RoleForms.prototype.addRole = function(teacher) {
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
				this.formRow.updateSelectList(positionsField, []);
			}
		});
	}
	this.formRow.addButtons(function() {
		// submit to server if 201 do the following
		var position = positionsField.options[positionsField.selectedIndex].textContent;
		var versionId = versionsField.options[versionsField.selectedIndex].textContent;
		var created = new Date().toISOString().substr(0,19);
		//rowIndex includes header, ergo -2 is top row
		that.table.insertRow(teacher.row.rowIndex - 1, 'memb', teacher.teacherId, null, null, position, versionId, created);
		that.formRow.close();
	});
	this.formRow.open();
};
RoleForms.prototype.removeRole = function(teacher, teacherRole) {
	var that = this;
	this.formRow.addButtons(function() {
		//submit to server if 200 do the following
		that.table.deleteRole(teacher, teacherRole);
		that.formRow.close();
	});
	this.formRow.open();
};
