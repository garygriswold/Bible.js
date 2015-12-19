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
	this.table = new RolesTable(this.state, this.numColumns, this.httpClient);
	Object.seal(this);
}
RolesViewModel.prototype.display = function() {
	var that = this;
	this.table.init();
	this.state.clearTeachers();
	iteratePersons(this.boss, 'boss');
	iteratePersons(this.self, 'self');
	iteratePersons(this.members, 'memb');
	storeHighestMember(this.members);
	
	function iteratePersons(list, type) {
		if (list) {
			var priorId = null;
			var versionRowCount = 0;
			for (var i=0; i<list.length; i++) {
				var row = list[i];
				that.table.insertRow(-1, type, row.teacherId, row.fullname, row.pseudonym, row.position, row.versionId, row.created);
			}
		}
	}
	function storeHighestMember(list) {
		var topPosition = 'teacher';
		for (var i=0; i<list.length; i++) {
			var row = list[i];
			if (row.position < topPosition) {
				topPosition = row.position;
			}
		}
		that.state.topMemberPosition = topPosition + '.';
	}
};
RolesViewModel.prototype.allCheckboxesOff = function() {
	this.table.allCheckboxesOff();
};
RolesViewModel.prototype.setProperties = function(status, results) {
	if (status === 200) {
		this.boss = results.boss;
		this.state.bossId = (this.boss && this.boss.length > 0) ? this.boss[0].teacherId : null;
		this.self = results.self;
		this.members = results.members;
		this.display();
	}
};
RolesViewModel.prototype.presentRoles = function() {
	var that = this;
	this.httpClient.get('/user', function(status, results) {
		if (status !== 200) {
			window.alert('Unexpected Error: ' + results.message);
		} else {
			that.setProperties(status, results);
		}
	});
};
RolesViewModel.prototype.registerNewPerson = function() {
	var rowPosition = this.boss.length + this.self.length + 2;
	var roleForms = new RoleForms(rowPosition, this.table, this.httpClient);
	roleForms.register();
};

