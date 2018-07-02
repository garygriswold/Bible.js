/**
* This function draws the rectangle icon that is used as the video
* button on the status bar.
*/
function drawVideoIcon(hite, color) {
	var lineThick = hite / 8.0;
	var lineYBeg = lineThick * 2.0;
	var lineXBeg = lineThick;
	var lineXEnd = hite - lineThick;
	var lineYEnd = hite - lineThick * 2.0;

	var canvas = document.createElement('canvas');
	canvas.setAttribute('height', hite);
	canvas.setAttribute('width', hite);
	var graphics = canvas.getContext('2d');
	
	//graphics.fillStyle = '#AAA';
    //graphics.fillRect(0,0,hite,hite);	

	graphics.beginPath();
	graphics.moveTo(lineXBeg, lineYBeg);
	graphics.lineTo(lineXEnd, lineYBeg);
	graphics.lineTo(lineXEnd, lineYEnd);
	graphics.lineTo(lineXBeg, lineYEnd);
	graphics.lineTo(lineXBeg, lineYBeg);
	graphics.closePath();

	graphics.lineWidth = lineThick;
	graphics.strokeStyle = color;
	graphics.lineJoin = 'round';
	graphics.stroke();
	return(canvas);
}