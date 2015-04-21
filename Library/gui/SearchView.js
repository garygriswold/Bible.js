/**
* This class provides the User Interface part of the concordance and search capabilities of the app.
* It does a lazy create of all of the objects needed.
* Each presentation of a searchView presents its last state and last found results.
*/
"use strict";

function SearchView(concordance) {
	this.concordance = concordance;
	Object.freeze(this);
};
SearchView.prototype.build = function() {

};