/**
* This function draws the 'X' that is used as a close
* button on any popup window.
*/
function drawCloseIcon(hite, color) {
	var lineThick = hite / 7.0;
	var spacer = lineThick / 2;

	var canvas = document.createElement('canvas');
	canvas.setAttribute('height', hite);
	canvas.setAttribute('width', hite);
	var graphics = canvas.getContext('2d');

	graphics.beginPath();
	graphics.moveTo(spacer, spacer);
	graphics.lineTo(hite - spacer, hite - spacer);
	graphics.moveTo(hite - spacer, spacer);
	graphics.lineTo(spacer, hite - spacer);
	graphics.closePath();

	graphics.lineWidth = hite / 5.0;
	graphics.strokeStyle = color;
	graphics.stroke();
	return(canvas);
}