/**
* This class draws the stop icon that is displayed
* when there are no search results.
*/
function StopIcon(color) {
	this.hite = window.innerHeight / 7;
	
	console.log('STOP', window.innerHeight, this.hite);
	this.centerIcon = (window.innerHeight - this.hite) / 2;
	console.log('SHOW', window.innerHeight, this.hite, this.centerIcon);
	this.color = color;
	this.iconDiv = document.createElement('div');
	this.iconDiv.setAttribute('style', 'text-align: center;');
	this.iconCanvas = null;
	Object.seal(this);
}
StopIcon.prototype.showIcon = function() {
	if (this.iconCanvas === null) {
		this.iconCanvas = this.drawIcon()
	}
	document.body.appendChild(this.iconDiv);
	this.iconDiv.appendChild(this.iconCanvas);

	TweenMax.set(this.iconCanvas, { y: - this.hite });
	TweenMax.to(this.iconCanvas, 0.5, { y: this.centerIcon });
};
StopIcon.prototype.hideIcon = function() {
	if (this.iconDiv && this.iconCanvas && this.iconDiv.hasChildNodes()) {
		this.iconDiv.removeChild(this.iconCanvas);
	}
	if (this.iconDiv && this.iconDiv.parentNode === document.body) {
		document.body.removeChild(this.iconDiv);
	}
};
StopIcon.prototype.drawIcon = function() {
	var lineThick = this.hite / 7.0;
	var radius = (this.hite / 2) - lineThick;
	var coordX = radius + lineThick;
	var coordY = radius + lineThick;
	var edgeX = coordX - radius / 1.5;
	var edgeY = coordY - radius / 1.5;

	var canvas = document.createElement('canvas');
	canvas.setAttribute('height', this.hite);
	canvas.setAttribute('width', this.hite);
	var graphics = canvas.getContext('2d');

	graphics.beginPath();
	graphics.arc(coordX, coordY, radius, 0, Math.PI*2, true);
	graphics.moveTo(edgeX, edgeY);
	graphics.lineTo(edgeX + radius * 1.5, edgeY + radius * 1.5);
	graphics.closePath();

	graphics.lineWidth = lineThick;
	graphics.strokeStyle = this.color;
	graphics.stroke();
	return(canvas);
};

// stop = new StopIcon(200, '#FF0000');
//stop.showIcon();
