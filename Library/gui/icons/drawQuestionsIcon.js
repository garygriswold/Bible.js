/**
* This function draws and icon that is used as a questions button
* on the StatusBar.
*/
function drawQuestionsIcon(hite, color) {
	var widthDiff = 1.25;

	var canvas = document.createElement('canvas');
	canvas.setAttribute('height', hite);
	canvas.setAttribute('width', hite * widthDiff);
	var graphics = canvas.getContext('2d');

	graphics.beginPath();
	drawOval(graphics);
	drawArc(graphics, hite);
	graphics.fillStyle = color;
   	graphics.fill();
	return(canvas);

	function drawOval(graphics) {
    	var centerX = 0;
    	var centerY = 0;
    	var radius = hite * 0.45;

    	graphics.save();
    	graphics.translate(canvas.width * 0.5, canvas.height * 0.45);
    	graphics.scale(widthDiff, 1);
    	graphics.arc(centerX, centerY, radius, 0, 2 * Math.PI, false);
    	graphics.restore();
    }
    
    function drawArc(graphics, hite) {
    	graphics.moveTo(hite * 0.28, hite);
    	graphics.bezierCurveTo(hite * 0.44, hite, hite * 0.66, hite * 0.73, hite * 0.72, hite * 0.45);
    	graphics.lineTo(hite * 0.94, hite * 0.45);
    	graphics.bezierCurveTo(hite * 0.9, hite * 0.73, hite * 0.54, hite, hite * 0.28, hite);
    	graphics.closePath();
    }
}

 