/**
* This table is used to define a list of buttons in a row.
*/
function ButtonRow(rowAbove) {
	this.colspan = 7;
	var tBody = rowAbove.parentElement;
	var next = findNextRow(tBody, rowAbove, this.colspan);
	this.row = tBody.insertRow(next);
	this.cell = this.row.insertCell();
	this.cell.setAttribute('class', 'role');
	this.cell.setAttribute('colspan', this.colspan);
	this.div = document.createElement('div');
	this.cell.appendChild(this.div);
	
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
	this.div.appendChild(button);
	button.addEventListener('click', callback);
};
ButtonRow.prototype.open = function() {
	TweenMax.from(this.div, 0.5, {height:0, scaleY:0, margin:0, padding:0});
};
ButtonRow.prototype.close = function() {
	var that = this;
	if (this.row) {
		TweenMax.to(this.row, 0.4, {padding:0, margin:0});
		TweenMax.to(this.cell, 0.4, {padding:0, margin:0});
		TweenMax.to(this.div, 0.5, {height:0, scaleY:0, margin:0, padding:0, onComplete:function() {
				that.row.parentElement.removeChild(that.row);
			}	
		});
	}
};