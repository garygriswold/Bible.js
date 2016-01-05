/**
* This class presents the table of contents, and responds to user actions.
*/
function TableContentsView(toc) {
	this.toc = toc;
	this.root = null;
	this.rootNode = document.createElement('div');
	this.rootNode.id = 'tocRoot';
	document.body.appendChild(this.rootNode);
	this.scrollPosition = 0;
	this.numberNode = document.createElement('span');
	this.numberNode.textContent = '0123456789';
	this.numberNode.setAttribute('style', "position: absolute; float: left; white-space: nowrap; visibility: hidden; font-family: sans-serif; font-size: 1.0rem");
	document.body.appendChild(this.numberNode);
	Object.seal(this);
}
TableContentsView.prototype.showView = function() {
	document.body.style.backgroundColor = '#FFF';
	if (! this.root) {
		this.root = this.buildTocBookList();
	}
	if (this.rootNode.children.length < 1) {
		this.rootNode.appendChild(this.root);
		window.scrollTo(0, this.scrollPosition);
	}
};
TableContentsView.prototype.hideView = function() {
	if (this.rootNode.children.length > 0) {
		this.scrollPosition = window.scrollY; // save scroll position till next use.
		for (var i=this.rootNode.children.length -1; i>=0; i--) {
			this.rootNode.removeChild(this.rootNode.children[i]);
		}
	}
};
TableContentsView.prototype.buildTocBookList = function() {
	var div = document.createElement('div');
	div.setAttribute('id', 'toc');
	div.setAttribute('class', 'tocPage');
	for (var i=0; i<this.toc.bookList.length; i++) {
		var book = this.toc.bookList[i];
		var bookNode = document.createElement('p');
		bookNode.setAttribute('id', 'toc' + book.code);
		bookNode.setAttribute('class', 'tocBook');
		bookNode.textContent = book.name;
		div.appendChild(bookNode);
		var that = this;
		bookNode.addEventListener('click', function(event) {
			var bookCode = this.id.substring(3);
			that.showTocChapterList(bookCode);
		});
	}
	return(div);
};
TableContentsView.prototype.showTocChapterList = function(bookCode) {
	var that = this;
	var book = this.toc.find(bookCode);
	if (book) {
		var root = document.createDocumentFragment();
		var table = document.createElement('table');
		table.setAttribute('class', 'tocChap');
		root.appendChild(table);
		var numCellPerRow = cellsPerRow();
		var numRows = Math.ceil(book.lastChapter / numCellPerRow);
		var chaptNum = 1;
		for (var r=0; r<numRows; r++) {
			var row = document.createElement('tr');
			table.appendChild(row);
			for (var c=0; c<numCellPerRow && chaptNum <= book.lastChapter; c++) {
				var cell = document.createElement('td');
				cell.setAttribute('id', 'toc' + bookCode + ':' + chaptNum);
				cell.setAttribute('class', 'tocChap');
				cell.textContent = chaptNum;
				row.appendChild(cell);
				chaptNum++;
				var that = this;
				cell.addEventListener('click', function(event) {
					var nodeId = this.id.substring(3);
					console.log('open chapter', nodeId);
					document.body.dispatchEvent(new CustomEvent(BIBLE.SHOW_PASSAGE, { detail: { id: nodeId }}));
				});
			}
		}
		var bookNode = document.getElementById('toc' + book.code);
		if (bookNode) {
			var saveYPosition = bookNode.getBoundingClientRect().top;
			removeAllChapters();
			bookNode.appendChild(root);
			scrollTOC(bookNode, saveYPosition);
		}
	}
	
	function cellsPerRow() {
		var width = that.numberNode.getBoundingClientRect().width;
		var cellWidth = Math.max(50, width * 0.3); // width of 3 chars or at least 50px
		var numCells = window.innerWidth * 0.8 / cellWidth;
		return(Math.floor(numCells));		
	}
	function removeAllChapters() {
		var div = document.getElementById('toc');
		if (div) {
			for (var i=div.children.length -1; i>=0; i--) {
				var bookNode = div.children[i];
				for (var j=bookNode.children.length -1; j>=0; j--) {
					var chaptTable = bookNode.children[j];
					bookNode.removeChild(chaptTable);
				}
			}
		}
	}
	function scrollTOC(bookNode, saveYPosition) {
		window.scrollBy(0, bookNode.getBoundingClientRect().top - saveYPosition); // Keeps bookNode in same position when node above is collapsed.
		
		var bookRect = bookNode.getBoundingClientRect();
		if (window.innerHeight < bookRect.top + bookRect.height) {
			// Scrolls booknode up when chapters are not in view.
			// limits scroll to bookRect.top -80 so that book name remains in view.
			window.scrollBy(0, Math.min(bookRect.top - 80, bookRect.top + bookRect.height - window.innerHeight));	
		}
	}
};

