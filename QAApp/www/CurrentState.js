/**
* This class contains the primary keys and any other data that must be passed 
* back and forth from view to view.
*/
"use strict";
function CurrentState() {
	this.teacherId = null;
	this.versionId = 'KJV';
	this.discourseId = null;
	this.questionTimestamp = null;
	this.answerTimestamp = null;
	Object.seal(this);
}