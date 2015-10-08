/**
* This class generates the DOM elements that control presentation and interactivity of the RolesView.html page
*/
"use strict";
function RolesViewModel(viewNavigator) {
	this.viewNavigator = viewNavigator;
	this.httpClient = viewNavigator.httpClient;
	this.state = viewNavigator.currentState;
	this.numColumns = 7;
	this.boss = null;
	this.self = null;
	this.members = null;
	this.buttonRow = null;
	Object.seal(this);
}
RolesViewModel.prototype.display = function() {
	var that = this;
	var root = document.getElementById('rolesBody');
	
	iteratePersons(this.boss, 'boss');
	iteratePersons(this.self, 'self');
	iteratePersons(this.members, 'memb');
	
	function iteratePersons(list, type) {
		var priorId = null;
		var versionRowCount = 0;
		for (var i=0; i<list.length; i++) {
			var row = list[i];
			var line = addNode(root, 'tr');
			if (row.teacherId !== priorId) {
				priorId = row.teacherId;
				versionRowCount = 1;
				
				var check1 = addNode(line, 'td');
				if (type === 'memb') {
					addCheckbox(check1, row.teacherId);
				}
				var name = addNode(line, 'td', row.fullname);
				var pseudo = addNode(line, 'td', row.pseudonym);
			} else {
				versionRowCount += 1;
				check1.setAttribute('rowspan', versionRowCount);
				name.setAttribute('rowspan', versionRowCount);
				pseudo.setAttribute('rowspan', versionRowCount);
			}
			if (type === 'boss') {
				addNode(line, 'td', 'super');
				var blank = addNode(line, 'td');
				blank.setAttribute('colspan', 4);
			} else {
				addNode(line, 'td', row.position);
				addNode(line, 'td', row.versionId);
				addNode(line, 'td', row.created);
				var check2 = addNode(line, 'td');
				addCheckbox(check2, row.teacherId, row.versionId, row.position);
			}
		}
	}
	
	function addNode(parent, elementType, content) {
		var element = document.createElement(elementType);
		element.setAttribute('class', 'role');
		if (content) {
			element.textContent = content;
		}
		parent.appendChild(element);
		return(element);
	}
	function addCheckbox(parent, teacherId, versionId, position) {
		var element = document.createElement('input');
		element.setAttribute('type', 'checkbox');
		var id = 'id.' + teacherId;
		if (versionId && position) {
			id += '.' + versionId + '.' + position;
		}
		element.setAttribute('id', id);
		element.setAttribute('class', 'role');
		parent.appendChild(element);
		element.addEventListener('change', function(event) {
			if (event.target.checked) {
				if (that.buttonRow === null) { // only turn button if none others are
					var tableRow = this.parentNode.parentNode;
					var parts = this.id.split('.');
					var clickedTeacherId = parts[1];
					var clickedVersionId = (parts.length > 2) ? parts[2] : null;
					var clickedPosition = (parts.length > 3) ? parts[3] : null;
					console.log('clicked', clickedTeacherId, clickedVersionId, clickedPosition)
					if (clickedVersionId) {
						that.displayVersionUpdateButtons(tableRow, clickedTeacherId, clickedVersionId, clickedPosition);
					} else {
						that.displayPersonUpdateButtons(tableRow, clickedTeacherId);
					}
				} else {
					event.target.checked = false;//don't turn on, because another button is on
				}
			} else {
				if (that.buttonRow) {
					that.buttonRow.close();
					that.buttonRow = null;
				}
			}
		});
	}
};
RolesViewModel.prototype.setProperties = function(status, results) {
	if (status === 200) {
		this.boss = results[0];
		this.self = (results.length > 0) ? results[1] : null;
		this.members = (results.length > 2) ? results[2] : null;
		this.display();
	}
};
RolesViewModel.prototype.presentRoles = function() {
	var that = this;
	this.httpClient.get('/user', function(status, results) {
		if (status !== 200) {
			if (results.message) window.alert(results.message);
			else window.alert('unknown error');
		}
		that.setProperties(status, results);
	});
};
RolesViewModel.prototype.displayPersonUpdateButtons = function(parent, teacherId) {
	this.buttonRow = new ButtonRow(parent, this.numColumns);
	this.buttonRow.addButton('Change Name', 'name.' + teacherId, function(event) {
		console.log('clicked name change button');
	});
	this.buttonRow.addButton('New Pass Phrase', 'pass.' + teacherId, function(event) {
		console.log('clicked new pass phrase');
	});
	this.buttonRow.addButton('Replace Person', 'repl.' + teacherId, function(event) {
		console.log('clicked replace person');
	});
	// This is only possible for someone who has a boss.
	this.buttonRow.addButton('Promote Person', 'prom.' + teacherId, function(event) {
		console.log('clicked promote person');
	});
	// This is not possible of authorizing person has no principal under them.
	this.buttonRow.addButton('Demote Person', 'demt.' + teacherId, function(event) {
		console.log('clicked demote person');
	})
};
RolesViewModel.prototype.displayNameUpdateButtons = function(parent, teacherId) {
	this.buttonRow = new ButtonRow(parent, this.numColumns);
	this.buttonRow.addButton('Change Name', 'name.' + teacherId, function(event) {
		console.log('Change name button is clicked');
	});
	this.buttonRow.addButton('New PassPhrase', 'pass.' + teacherId, function(event) {
		console.log('New Passphrase button click');
	});
};
RolesViewModel.prototype.displayVersionUpdateButtons = function(parent, teacherId, versionId, position) {
	this.buttonRow = new ButtonRow(parent, this.numColumns);
	this.buttonRow.addButton('Add Role', 'add.' + teacherId, function(event) {
		console.log('Add Role button click');
	});
	this.buttonRow.addButton('Remove Role', 'rem.' + teacherId + '.' + versionId + '.' + position, function(event) {
		console.log('Remove role button click');
	});
};
