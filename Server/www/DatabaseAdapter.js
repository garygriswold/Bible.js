/**
* This class provides a convenient JS interface to a SQL database.
* The interface is intended to be useful for any kind of database,
* but this implementation is for SQLite3.
*/
function DatabaseAdapter() {
	
}
DatabaseAdapter.prototype.create = function() {
	// Batch all of the SQL drop and create statements here.	
};
DatabaseAdapter.prototype.selectUser = function() {
	// ?????? What uses this????
};
DatabaseAdapter.prototype.insertUser = function() {
	// Should this really be called user?
	// Used by tran registerUser
	// This should also add initial privilege, or default for one language
};
DatabaseAdapter.prototype.updateUser = function() {
	// Used by tran update User
};
DatabaseAdapter.prototype.deleteUser = function() {
	// Used by tran delete User
	// Should delete user's privileges
};
DatabaseAdapter.prototype.selectPositions = function() {
	// ????? What uses this????
};
DatabaseAdapter.prototype.insertPosition = function() {
	// Used by tran insertPosotion
};
DatabaseAdapter.prototype.deletePosition = function() {
	// Used by tran deletePosition
};

DatabaseAdapter.prototype.insertQuestion = function() {
	// Create Converstation and Message rows
	// Used by tran insertQuestion	
};
DatabaseAdapter.prototype.updateQuestion = function() {
	// Update the message record
	// Used by tran updateQuestion
};
DatabaseAdapter.prototype.deleteQuestion = function() {
	// Deletes Message and Conversation
	// Used by tran deleteQuestion	
};
DatabaseAdapter.prototype.assignQuestion = function() {
	// Update Conversation status and add Instructor ID
	// And return Question
	// Used by tran assignQuestion
};
DatabaseAdapter.prototype.returnQuestion = function() {
	// Update Conversation status and Instructor ID	
	// Used by tran returnQuestion
};
DatabaseAdapter.prototype.selectAnswers = function() {
	// Retrieve any answers to questions
	// Used by tran getAnswers
};
DatabaseAdapter.prototype.insertAnswer = function() {
	// Update Conversation and Insert Message
	// Used by tran sendAnser
};
DatabaseAdapter.prototype.updateAnswer = function() {
	// Used by tran updateAnswer
};
DatabaseAdapter.prototype.deleteAnswer = function() {
	// Used by tran deleteAnswer
};
DatabaseAdapter.prototype.selectDraft = function() {
	// used by tran getDraft
};
DatabaseAdapter.prototype.replaceDraft = function() {
	// Save Draft answer (or question?)
	// using replace
	// delete of draft should not be needed, it will be overwritten if it expires
	// used by tran saveDraft
};
DatabaseAdapter.prototype.deleteDraft = function() {
	// used by tran delete Draft, not sure if this is needed.	
};

