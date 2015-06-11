/**
* This is a test harness for unit testing the drawing of icons
*/
function iconsTest() {
	var size = 200;
	var color = '#777777';
	var layoutStyle = 'display: inline-block; border: solid';

	placeIcon(drawTOCIcon(size, color));

	placeIcon(drawSearchIcon(size, color));

	placeIcon(drawQuestionsIcon(size, color));

	placeIcon(drawSettingsIcon(size, color));

	placeIcon(drawSendIcon(size, color));

	function placeIcon(icon) {
		var button = document.createElement('div');
		button.setAttribute('style', layoutStyle);
		document.body.appendChild(button);
		button.appendChild(icon);		
	}
}

