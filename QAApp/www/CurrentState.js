/**
* This class contains the primary keys and any other data that must be passed 
* back and forth from view to view.
*/
"use strict";
function CurrentState() {
	this.teacherId = null;
	this.isBoard = false;
	this.isSuper = false;
	this.principal = null;
	this.teacher = null;
	this.versionId = null;
	this.discourseId = null;
	this.questionTimestamp = null;
	this.answerTimestamp = null;
	Object.seal(this);
}
CurrentState.prototype.canManageRoles = function() {
	return(this.principal || this.isSuper || this.isBoard);	
};
CurrentState.prototype.canSeeAllVersions = function() {
	return(this.isSuper || this.isBoard);
};
CurrentState.prototype.canSeeVersion = function(versionId) {
	return((this.principal && this.principal[versionId]) || (this.teacher && this.teacher[versionId]));
};
CurrentState.prototype.canAnswer = function(versionId) {
	(this.teacher && this.teacher[versionId]);
};
CurrentState.prototype.setRoles = function(roles) {
	this.clearRoles();
	if (roles && roles.length) {
		for (var i=0; i<roles.length; i++) {
			var role = roles[i];
			switch(role.position) {
				case 'board':
					this.isBoard = true;
					break;
				case 'super':
					this.isSuper = true;
					break;
				case 'principal':
					if (this.principal === null) {
						this.principal = {};
					}
					this.principal[role.versionId] = true;
					break;
				case 'teacher':
					if (this.teacher === null) {
						this.teacher = {};
					}
					this.teacher[role.versionId] = true;
					break;
				case 'removed':
					break;
				default:
					throw new Error('Unknown position in CurrentState.setRoles');
			}
		}
	}
};
CurrentState.prototype.clearRoles = function() {
	this.isBoard = false;
	this.isSuper = false;
	this.principal = null;
	this.teacher = null;		
};