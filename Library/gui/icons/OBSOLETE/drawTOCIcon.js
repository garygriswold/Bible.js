/**
* This function draws an icon that is used as a TOC button
* on the StatusBar.
*/
function drawTOCIcon(hite, color) {
	var lineThick = hite / 8.0;
	var line1Y = lineThick * 1.5;
	var lineXBeg = lineThick;
	var lineXEnd = hite - lineThick;
	var line2Y = lineThick * 2.5 + line1Y;
	var line3Y = lineThick * 2.5 + line2Y;

	var canvas = document.createElement('canvas');
	canvas.setAttribute('height', hite);
	canvas.setAttribute('width', hite);// + lineXBeg * 0.5);
	var graphics = canvas.getContext('2d');
	
	//graphics.fillStyle = '#AAA';
    //graphics.fillRect(0,0,hite,hite);

	graphics.beginPath();
	graphics.moveTo(lineXBeg, line1Y);
	graphics.lineTo(lineXEnd, line1Y);
	graphics.moveTo(lineXBeg, line2Y);
	graphics.lineTo(lineXEnd, line2Y);
	graphics.moveTo(lineXBeg, line3Y);
	graphics.lineTo(lineXEnd, line3Y);

	graphics.lineWidth = lineThick;
	graphics.lineCap = 'square';
	graphics.strokeStyle = color;
	graphics.stroke();

	return(canvas);
}