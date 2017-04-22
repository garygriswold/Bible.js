/**
* This function draws and icon that is used as a send arrow button
* on the QuestionsView input block.
*/
function drawSendIcon(hite, color) {
	var widthDiff = 1.25;

	var canvas = document.createElement('canvas');
	canvas.setAttribute('height', hite);
	canvas.setAttribute('width', hite * widthDiff);
	var graphics = canvas.getContext('2d');

	var lineWidth = hite / 7.0;
	drawArrow(graphics, lineWidth);
	return(canvas);

	function drawArrow(graphics, lineWidth) {
		var middle = canvas.height * 0.5;
		var widt = canvas.width;
		var doubleLineWidth = lineWidth * 2.0;
		var tripleLineWidth = lineWidth * 3.5;
		var controlX = widt - lineWidth * 2.5;

		graphics.beginPath();
		graphics.moveTo(lineWidth, middle);
		graphics.lineTo(widt - 2 * lineWidth, middle);
		graphics.strokeStyle = color;
		graphics.lineWidth = lineWidth;
		graphics.stroke();

		graphics.beginPath();
		graphics.moveTo(widt - lineWidth, middle);
		graphics.lineTo(widt - tripleLineWidth, middle - doubleLineWidth);

		graphics.moveTo(widt - lineWidth, middle);
		graphics.lineTo(widt - tripleLineWidth, middle + doubleLineWidth);

		graphics.bezierCurveTo(controlX, middle, controlX, middle, widt - tripleLineWidth, middle - doubleLineWidth);

		graphics.fillStyle = color;
		graphics.fill();
	}
}