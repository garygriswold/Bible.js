/**
* This function draws the spyglass that is used as the search
* button on the status bar.
*/
function drawSearchIcon(hite, color) {
	var lineThick = hite / 8.0;
	var radius = (hite / 2) - (lineThick * 2.0);
	var coordX = radius + (lineThick * 1.5);
	var coordY = radius + lineThick * 1.25;
	var edgeX = coordX + radius / 2 + 2;
	var edgeY = coordY + radius / 2 + 2;

	var canvas = document.createElement('canvas');
	canvas.setAttribute('height', hite);
	canvas.setAttribute('width', hite + lineThick);
	var graphics = canvas.getContext('2d');
	
	//graphics.fillStyle = '#AAA';
    //graphics.fillRect(0,0,hite,hite);

	graphics.beginPath();
	graphics.arc(coordX, coordY, radius, 0, Math.PI*2, true);
	graphics.moveTo(edgeX, edgeY);
	graphics.lineTo(edgeX + radius, edgeY + radius);
	graphics.closePath();

	graphics.lineWidth = lineThick;
	graphics.strokeStyle = color;
	graphics.stroke();
	return(canvas);
}