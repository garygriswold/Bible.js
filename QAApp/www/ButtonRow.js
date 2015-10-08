/**
* This table is used to define a list of buttons in a row.
*/
function ButtonRow(rowAbove, colspan) {
	var next = findNextRow(rowAbove, colspan);
		
	this.row = document.createElement('tr');
	rowAbove.parentNode.insertBefore(this.row, next);
	var cell = document.createElement('td');
	cell.setAttribute('class', 'role');
	cell.setAttribute('colspan', colspan);
	this.row.appendChild(cell);
	this.parentCell = cell;
	
	function findNextRow(rowAbove, colspan) {
		var after = false;
		var parent = rowAbove.parentElement;
		var children = parent.childNodes;
		for (var i=0; i<children.length; i++) {
			var child = children[i];
			if (child.nodeType === 1 && child.nodeName === 'TR') {
				if (after && child.childNodes.length === colspan) {
					return(child);
				}
				if (child === rowAbove) {
					after = true;
				}
			}
		}
		return(null);
	}
}
ButtonRow.prototype.addButton = function(label, id, callback) {
	var button = document.createElement('button');
	button.setAttribute('id', id);
	button.setAttribute('class', 'button bigrounded blue');
	button.textContent = label;
	this.parentCell.appendChild(button);
	button.addEventListener('click', callback);
};
ButtonRow.prototype.close = function() {
	if (this.row) {
		this.row.parentElement.removeChild(this.row);
	}
};