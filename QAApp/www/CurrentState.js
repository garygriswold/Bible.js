/**
* This class contains the internal data model that is used by the Application.
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
	this.roles = {};
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
CurrentState.prototype.getTeacher = function(teacherId) {
	return(this.teachers[teacherId]);	
};
CurrentState.prototype.addTeacher = function(teacherId, nameCell, pseudoCell, row) {
	this.teachers[teacherId] = {fullname:nameCell, pseudonym:pseudoCell, row:row};
};
CurrentState.prototype.removeTeacher = function(teacherId) {
	delete this.teachers[teacherId];
};
CurrentState.prototype.getRole = function(teacherId, position, version) {
	return(this.roles[this.roleKey(teacherId, position, version)]);	
};
CurrentState.prototype.addRole = function(teacherId, position, version, positionCell, versionCell, createdCell, row) {
	var key = this.roleKey(teacherId, position, version);
	this.roles[key] = {position:positionCell, versionId:versionCell, created:createdCell, row:row};
};
CurrentState.prototype.removeRole = function(teacherId, position, version) {
	var key = this.roleKey(teacherId, position, version);
	delete this.roles[key];
};
CurrentState.prototype.roleKey = function(teacherId, position, version) {
	return(teacherId + '.' + position + '.' + version);
};
CurrentState.prototype.clearCache = function() {
	this.teachers = {};
	this.roles = {};
};