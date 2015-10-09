/**
* This table is used to define a list of buttons in a row.
*/
function ButtonRow(rowAbove, colspan) {
	var tBody = rowAbove.parentElement;
	var next = findNextRow(tBody, rowAbove, colspan);
	this.row = tBody.insertRow(next);
	this.cell = this.row.insertCell();
	this.cell.setAttribute('class', 'role');
	this.cell.setAttribute('colspan', colspan);
	
	function findNextRow(tBody, rowAbove, colspan) {
		var after = false;
		var rows = tBody.rows;
		for (var i=0; i<rows.length; i++) {
			var row = rows[i];
			if (after && row.cells.length === colspan) {
				return(i);
			}
			if (row === rowAbove) {
				after = true;
			}
		}
		return(-1);
	}
}
ButtonRow.prototype.addButton = function(label, id, callback) {
	var button = document.createElement('button');
	button.setAttribute('id', id);
	button.setAttribute('class', 'button bigrounded blue');
	button.setAttribute('style', 'margin: 10px 30px 10px 30px');
	button.textContent = label;
	this.cell.appendChild(button);
	button.addEventListener('click', callback);
};
ButtonRow.prototype.close = function() {
	if (this.row) {
		//TweenMax.to(this.cell, 0.5, {scaleY:0, opacity:0.2, onComplete:finishRemove});
		this.row.parentElement.removeChild(this.row);
	}
};