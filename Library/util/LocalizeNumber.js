/**
* This class will convert a number to a localized representation of the same number.
* This is used primarily for converting chapter and verse numbers, since USFM and USX
* always represent those numbers in ASCII.
*/
function LocalizeNumber(locale) {
	this.locale = locale;
	switch(local) {
		case 'ar':
			this.numberOffset = 0x0660 - 0x0030;
			break;
		case 'fa':
			this.numberOffset = 0x06F0 - 0x0030;
			break;
		default:
			this.offset = 0;
			break;
	}
}
LocalizeNumber.prototype.toLocale = function(number) {
	return(this.convert(number, this.numberOffset));
};
LocalizeNumber.prototype.toAscii = function(number) {
	return(this.convert(number, - this.numberOffset));
};
LocalizeNumber.prototype.convert = function(number, offset) {
	if (offset === 0) return(number);
	var result = [];
	for (var i=0; i<number.length; i++) {
		var char = number.charCodeAt(i);
		var local = parseInt(char + offset, 16);
		result.push(String.fromCharCode(local));
	}
	return(result.join(''));
};