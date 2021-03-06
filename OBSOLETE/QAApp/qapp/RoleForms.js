/**
*
*/
"use strict";
function RoleForms(rowIndex, table, httpClient) {
	this.formRowIndex = rowIndex;
	this.table = table;
	this.state = table.state;
	this.httpClient = httpClient;
	this.formRow = new FormRow(table.tBody, rowIndex);
}
RoleForms.prototype.register = function() {
	var that = this;
	this.formRow.addBlank(1);
	var nameField = this.formRow.addName('');
	var pseudoField = this.formRow.addPseudo('');
	var posButtons = this.addRoleButtons();
	var positionsField = posButtons.position;
	var versionsField = posButtons.version;
	this.formRow.addButtons(function() {
		var validMsg = that.formRow.validateFields();
		if (validMsg) {
			window.alert(validMsg);
		} else {
			var fullname = nameField.value;
			var pseudonym = pseudoField.value;
			var position = positionsField.options[positionsField.selectedIndex].textContent;
			var versionId = versionsField.options[versionsField.selectedIndex].textContent;
			var created = new Date().toISOString().substr(0,19);
			var postData = {fullname:fullname, pseudonym:pseudonym, position:position, versionId:versionId};
			that.httpClient.put('/user', postData, function(status, results) {
				if (status === 201) {
					var teacherId = results.teacherId;
					var passPhrase = results.passPhrase;  /// This must be displayed for user to record.
					that.table.insertRow(that.formRowIndex, 'memb', teacherId, fullname, pseudonym, position, versionId, created);
					that.formRow.close();
				} else {
					that.displayError(status, results);
				}	
			});
		}
	});
	this.formRow.open();
};
RoleForms.prototype.name = function(teacher) {
	var that = this;
	this.formRow.addBlank(1);
	var nameField = this.formRow.addName(teacher.fullname.textContent);
	var pseudoField = this.formRow.addPseudo(teacher.pseudonym.textContent);
	this.formRow.addMessage(2, "You may change a user's name or pseudonym.");
	this.formRow.addButtons(function() {
		var validMsg = that.formRow.validateFields();
		if (validMsg) {
			window.alert(validMsg);
		} else {
			var fullname = nameField.value;
			var pseudonym = pseudoField.value;
			var postData = {teacherId:teacher.teacherId, fullname:fullname, pseudonym:pseudonym};
			that.httpClient.post('/user', postData, function(status, results) {
				if (status === 200) {
					teacher.fullname.textContent = fullname;
					teacher.pseudonym.textContent = pseudonym;
					that.formRow.close();
				} else {
					that.displayError(status, results);
				}
			});
		}
	});
	this.formRow.open();
};
RoleForms.prototype.passPhrase = function(teacher) {
	var that = this;
	var message = 'When you create a new Pass Phrase, the user will not be able to access their account until after they login with their new Pass Phrase.';
	this.formRow.addMessage(5, message);
	this.formRow.addButtons(function() {
		that.httpClient.get('/phrase/' + teacher.teacherId + '/' + that.bestLanguage(teacher), function(status, results) {
			if (status === 200) {
				message = 'Be sure to give this user their new Pass Phrase, exactly.';
				that.formRow.setMessage(0, message, results.passPhrase);
				that.formRow.setDoneButton(1);				
			} else {
				that.displayError(status, results);
			}
		});
	});
	this.formRow.open();
};
RoleForms.prototype.replace = function(teacher) {
	var that = this;
	this.formRow.addBlank(1);
	var nameField = this.formRow.addName('');
	var pseudoField = this.formRow.addPseudo('');
	this.formRow.addMessage(2, 'Use this to replace one person with a another person.');
	this.formRow.addButtons(function() {
		var validMsg = that.formRow.validateFields();
		if (validMsg) {
			window.alert(validMsg);
		} else {
			var fullname = nameField.value;
			var pseudonym = pseudoField.value;
			var postData = {teacherId:teacher.teacherId, fullname:fullname, pseudonym:pseudonym};
			that.httpClient.post('/user', postData, function(status, results) {
				if (status === 200) {
					teacher.fullname.textContent = fullname;
					teacher.pseudonym.textContent = pseudonym;
					that.httpClient.get('/phrase/' + teacher.teacherId + '/' + that.bestLanguage(teacher), function(status, results) {
						if (status === 200) {
							var message = 'Be sure to give this user their new Pass Phrase, exactly.';
							that.formRow.setMessage(3, message, results.passPhrase);
							that.formRow.setDoneButton(4);
						} else {
							that.displayError(status, results);
						}			
					});		
				} else {
					that.displayError(status, results);
				}
			});
		}		
	});
	this.formRow.open();
};
RoleForms.prototype.bestLanguage = function(teacher) {
	var roles = Object.keys(teacher.roles);
	for(var i=0; i<roles.length; i++) {
		var parts = roles[i].split('.');
		if (parts[1] && parts[1].length > 2) {
			return(parts[1])
		}
	}
	return('WEB');
};
RoleForms.prototype.promote = function(teacher) {
	var that = this;
	this.formRow.addMessage(4, 'Use this to move a person out of your authority to the person who authorizes you.');
	this.formRow.addButtons(function() {
		var postData = {authorizerId:that.state.bossId, teacherId:teacher.teacherId};
		that.httpClient.post('/auth', postData, function(status, results) {
			if (status === 200) {
				that.table.deletePerson(teacher);
				that.formRow.close();
			} else {
				that.displayError(status, results);
			}
		});
	});
	this.formRow.open();
};
RoleForms.prototype.demote = function(teacher) {
	var that = this;
	this.formRow.addBlank(1);
	var teacherState = getRoleState(teacher);
	var qualified = findQualifiedMembers();
	var personsField = this.formRow.addQualified(qualified);
	this.formRow.addMessage(3, 'Use this to move a person out of your authority to one of your members.');
	this.formRow.addButtons(function() {
		var selected = personsField.options[personsField.selectedIndex];
		var postData = {authorizerId:selected.value, teacherId:teacher.teacherId};
		that.httpClient.post('/auth', postData, function(status, results) {
			if (status === 200) {
				that.table.deletePerson(teacher);
				that.formRow.close();	
			} else {
				that.displayError(status, results);
			}
		});
	});
	this.formRow.open();	
	
	function findQualifiedMembers() {
		var qualified = [];
		var memberKeys = Object.keys(that.state.teachers);
		for (var i=0; i<memberKeys.length; i++) {
			var member = that.state.getTeacher(memberKeys[i]);
			var memberState = getRoleState(member);
			if (isQualifiedTest(memberState, teacherState)) {
				qualified.push({value:member.teacherId, label:member.fullname.textContent});
			}
		}
		return(qualified);
	}
	function getRoleState(teacher) {
		var roles = [];
		var roleKeys = Object.keys(teacher.roles);
		for (var i=0; i<roleKeys.length; i++) {
			var parts = roleKeys[i].split('.');
			roles.push({position:parts[0], versionId:parts[1]});
		}
		var roleState = new CurrentState();
		roleState.setRoles(roles);
		return(roleState);
	}
	function isQualifiedTest(member, teacher) {
		if (member.isBoard && ! teacher.isBoard) {
			return(true);
		}
		if (member.isDirector && ! teacher.isDirector) {
			return(true);
		}
		if (member.isPrincipal && ! teacher.isPrincipal) {
			for (var i=0; i<teacher.principal.length; i++) {
				var teacherVersion = teacher.principal[i];
				if (member.principal.indexOf(teacherVersion) < 0) {
					return(false);
				}
			}
			return(true);
		}
	}
};
RoleForms.prototype.addRole = function(teacher) {
	var that = this;
	this.formRow.addMessage(3, "Use this to give this person a new responsibility.");
	var posButtons = this.addRoleButtons();
	var positionsField = posButtons.position;
	var versionsField = posButtons.version;
	this.formRow.addButtons(function() {
		var position = positionsField.options[positionsField.selectedIndex].textContent;
		var versionId = versionsField.options[versionsField.selectedIndex].textContent;
		var created = new Date().toISOString().substr(0,19);
		var postData = {teacherId:teacher.teacherId, position:position, versionId:versionId};
		that.httpClient.put('/position', postData, function(status, results) {
			if (status === 201) {
				that.table.insertRow(teacher.row.rowIndex - 1, 'memb', teacher.teacherId, null, null, position, versionId, created);
				that.formRow.close();
			} else {
				that.displayError(status, results);
			}
		});
	});
	this.formRow.open();
};
RoleForms.prototype.addRoleButtons = function() {
	var positions = this.state.positionsCanManage();
	console.log('POSITIONS', positions);
	var positionsField = this.formRow.addPosition(positions, 'teacher');
	console.log('PRINCIPAL', this.state.principal);
	var versions = (this.state.principal) ? Object.keys(this.state.principal) : null;
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
	return({position:positionsField, version:versionsField});		
};
RoleForms.prototype.removeRole = function(teacher, role) {
	var that = this;
	this.formRow.addMessage(5, "Use this to remove a responsibility from this person.");
	this.formRow.addButtons(function() {
		var postData = {teacherId:teacher.teacherId, position:role.position.textContent, versionId:role.versionId.textContent};
		that.httpClient.delete('/position', postData, function(status, results) {
			if (status === 200) {
				that.table.deleteRole(teacher, role);
				that.formRow.close();	
			} else {
				that.displayError(status, results);
			}
		});
	});
	this.formRow.open();
};
RoleForms.prototype.roleButtons = function() {
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
};
RoleForms.prototype.displayError = function(status, results) {
	window.alert('Unexpected Error: ' + results.message);	
};
