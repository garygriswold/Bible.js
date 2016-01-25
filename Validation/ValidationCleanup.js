/**
* After validation is complete and manual inspection of validation results in the approval of the file,
* this program should be run in order to remove all extraneous data that was put into the Bible database
* and it should run vacuum at the end.
*/
function ValidationCleanup() {
	// The first step should be to make a copy of the database so that there is a permanent archive of the
	// validation process.
	// All other described steps should be on the copy that will be given to customers.
}
ValidationCleanup.prototype.function = concordance() {
	// 1. This should only be run after validation has been manually approved.
	// 2. It should delete the tables that were generated for validation.
	// 3. It should set the refPosition column = null
};
/**
* Note: vacuum can change any rowids.  And rowid dependancies in tables must be redone here after vacuum.
*/
ValidationCleanup.prototype.function = close() {
	// 1. This should run vacuum on the database.
	// 2. close database
};
