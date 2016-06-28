/**
* This class will convert a number to a localized representation of the same number.
* This is used primarily for converting chapter and verse numbers, since USFM and USX
* always represent those numbers in ASCII.
*/
function LocalizeNumber(silCode) {
	this.silCode = silCode;
	switch(silCode) {
		case 'arb': // Arabic
			this.numberOffset = 0x0660 - 0x0030;
			break;
		case 'pes': // Persian
			this.numberOffset = 0x06F0 - 0x0030;
			break;
		default:
			this.numberOffset = 0;
			break;
	}
	Object.freeze(this);
}
LocalizeNumber.prototype.toLocal = function(number) {
	return(this.convert(number, this.numberOffset));
};
LocalizeNumber.prototype.toAscii = function(number) {
	return(this.convert(number, - this.numberOffset));
};
LocalizeNumber.prototype.convert = function(number, offset) {
	if (offset === 0) return(number);
	var result = [];
	for (var i=0; i<number.length; i++) {
		result.push(String.fromCharCode(number.charCodeAt(i) + offset));
	}
	return(result.join(''));
};