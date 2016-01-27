/**
* This class is a false adapter.  Since the AssetBuilder class excepts all Builders to have an
* adapter this can be used whenever there is no adapter.
*/
function FauxAdapter() {
	this.className = 'FauxAdapter';
	Object.freeze(this);
}
FauxAdapter.prototype.drop = function(callback) {
	callback();
};
FauxAdapter.prototype.create = function(callback) {
	callback();
};