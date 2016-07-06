/**
* At this time, CSS has margin-left and margin-right capabilities, but it does not 
* have margin-right and margin-left capabilities.  That is, it does not have the 
* ability to vary the margin per direction of the text.
* https://www.w3.org/wiki/Dynamic_style_-_manipulating_CSS_with_JavaScript
*/
function DynamicCSS() {
}
DynamicCSS.prototype.setDirection = function(direction) {
	document.body.setAttribute('style', 'direction: ' + direction);
	var sheet = document.styleSheets[0];
	if (direction === 'ltr') {
		console.log('*************** setting ltr margins');
		sheet.addRule("#codexRoot", 	"margin-left: 8%; 		margin-right: 6%;");
		sheet.addRule("p.io, p.io1", 	"margin-left: 1.0rem; 	margin-right: 0;");
		sheet.addRule("p.io2", 			"margin-left: 2.0rem; 	margin-right: 0;");
		sheet.addRule("p.li, p.li1", 	"margin-left: 2.0rem;	margin-right: 0;");
		sheet.addRule("p.q, p.q1",  	"margin-left: 3.0rem; 	margin-right: 0;");
		sheet.addRule("p.q2", 			"margin-left: 3.0rem; 	margin-right: 0;");
	} else {
		console.log('**************** setting rtl margins');
		sheet.addRule("#codexRoot", 	"margin-right: 8%; 		margin-left: 6%;");
		sheet.addRule("p.io, p.io1",	"margin-right: 1.0rem;	margin-left: 0;");
		sheet.addRule("p.io2",			"margin-right: 2.0rem;	margin-left: 0;");
		sheet.addRule("p.li, p.li1",	"margin-right: 2.0rem;	margin-left: 0;");
		sheet.addRule("p.q, p.q1",  	"margin-right: 3.0rem;	margin-left: 0;");
		sheet.addRule("p.q2", 			"margin-right: 3.0rem; 	margin-left: 0;");
	}	
};

