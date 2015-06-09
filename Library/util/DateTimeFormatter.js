/**
* This class performs localized date and time formatting.
* It is written as a distinct class, because the way this is done
* using Cordova is different than how it is done using WebKit/Node.js
*/
function DateTimeFormatter() {
	// get the students country and language information
	this.language = 'en';
	this.country = 'US';
	this.locale = this.language + '-' + this.country;
	Object.freeze(this);
}
DateTimeFormatter.prototype.localDate = function(date) {
	var options = { year: 'numeric', month: 'long', day: 'numeric' };
	return(date.toLocaleString('en-US', options));
};
DateTimeFormatter.prototype.localTime = function(date) {
	var options = { hour: 'numeric', minute: 'numeric', second: 'numeric' };
	return(date.toLocaleString('en-US', options));
};
DateTimeFormatter.prototype.localDatetime = function(date) {
	var options = { year: 'numeric', month: 'long', day: 'numeric', hour: 'numeric', minute: 'numeric', second: 'numeric' };
	return(date.toLocaleString('en-US', options));
};
