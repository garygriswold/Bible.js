/**
* This class contains the primary keys and any other data that must be passed 
* back and forth from view to view.
*/
"use strict";
function CurrentState() {
	this.teacherId = null;
	this.isBoard = false;
	this.isDirector = false;
	this.principal = null;
	this.teacher = null;
	this.versionId = null;
	this.discourseId = null;
	this.questionTimestamp = null;
	this.answerTimestamp = null;
	this.teachers = {};
	Object.seal(this);
}
CurrentState.prototype.canManageRoles = function() {
	return(this.principal || this.isDirector || this.isBoard);	
};
CurrentState.prototype.canSeeAllVersions = function() {
	return(this.isDirector || this.isBoard);
};
CurrentState.prototype.canSeeVersion = function(versionId) {
	return((this.principal && this.principal[versionId]) || (this.teacher && this.teacher[versionId]));
};
CurrentState.prototype.canAnswer = function(versionId) {
	return(this.teacher && this.teacher[versionId]);
};
CurrentState.prototype.positionsCanManage = function() {
	if (this.isBoard) {
		return(['teacher', 'principal', 'director']);
	} else if (this.isDirector) {
		return(['teacher', 'principal']);
	} else if (this.principal) {
		return(['teacher']);
	} else {
		return([]);
	}
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
				case 'director':
					this.isDirector = true;
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
	this.isDirector = false;
	this.principal = null;
	this.teacher = null;		
};