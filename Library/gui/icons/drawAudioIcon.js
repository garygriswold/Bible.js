/**
* This function draws the Audio Speaker button for the Header
*/
function drawAudioIcon(hite, color) {
	var halfHite = hite / 2.0;
	var lineThick = hite / 8.0;
	var halfLine = lineThick / 2.0;
	

	var canvas = document.createElement('canvas');
	canvas.setAttribute('height', hite);
	canvas.setAttribute('width', hite);
	var graphics = canvas.getContext('2d');

	graphics.beginPath();
	// top line
	graphics.moveTo(hite - lineThick, lineThick);
	graphics.lineTo(lineThick, halfHite - halfLine);
	// bottom line
	graphics.moveTo(hite - lineThick, hite - lineThick);
	graphics.lineTo(lineThick, halfHite + halfLine);
	// left line
	var leftLen = lineThick + Math.sqrt(halfLine * halfLine / 2.4);
	graphics.moveTo(leftLen, halfHite - lineThick * 1.3);
	graphics.lineTo(leftLen, halfHite + lineThick * 1.3);

	graphics.closePath();

	graphics.lineWidth = lineThick;
	graphics.strokeStyle = color;
	graphics.stroke();
	
	graphics.lineWidth = lineThick / 2.0;
	//graphics.strokeStyle = '#FF0000';
	
	var center = hite / 5.3333;
	graphics.beginPath();
	graphics.arc(center, hite/2, hite * 0.70, -0.40, 0.40, false);
	graphics.stroke();
	
	// outer arc
	graphics.beginPath();
	graphics.arc(center, hite/2, hite * 0.55, -0.40, 0.40, false);
	graphics.stroke();
	
	// inner arc
	graphics.beginPath();
	graphics.arc(center, hite/2, hite * 0.40, -0.40, 0.40, false);
	graphics.stroke();
	
	// inner arc
	graphics.beginPath();
	graphics.arc(center, hite/2, hite * 0.25, -0.40, 0.40, false);
	graphics.stroke();
	
	return(canvas);
}