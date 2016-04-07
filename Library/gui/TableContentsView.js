/**
* This class presents the table of contents, and responds to user actions.
*/
function TableContentsView(toc, version) {
	this.toc = toc;
	this.version = version;
	this.root = null;
	this.dom = new DOMBuilder();
	this.rootNode = this.dom.addNode(document.body, 'div', null, null, 'tocRoot');
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
	var that = this;
	var div = document.createElement('div');
	div.setAttribute('id', 'toc');
	div.setAttribute('class', 'tocPage');
	appendVersionAttribution(div);
	for (var i=0; i<this.toc.bookList.length; i++) {
		var book = this.toc.bookList[i];
		var bookNode = that.dom.addNode(div, 'p', 'tocBook', book.name, 'toc' + book.code);
		
		var that = this;
		bookNode.addEventListener('click', function(event) {
			var bookCode = this.id.substring(3);
			that.showTocChapterList(bookCode);
		});
	}
	return(div);
	
	function appendVersionAttribution(parent) {
		var versionName = (that.version.localVersionName) ? that.version.localVersionName : that.version.localLanguageName;
		that.dom.addNode(parent, 'p', 'versionName', versionName);
		var copyNode = that.dom.addNode(parent, 'p', 'copyright');
		
		if (that.version.copyrightYear === 'PUBLIC') {
			that.dom.addNode(copyNode, 'span', 'copyright', 'Public Domain');
		} else {
			var copy = String.fromCharCode('0xA9') + String.fromCharCode('0xA0');
			var copyright = (that.version.copyrightYear) ?  copy + that.version.copyrightYear + ', ' : copy;
			that.dom.addNode(copyNode, 'span', 'copyright', copyright);
			var ownerNode = that.dom.addNode(copyNode, 'span', 'copyright', that.version.ownerName);
			if (that.version.ownerURL) {
				ownerNode.setAttribute('style', 'color: #0000FF; text-decoration: underline');
				ownerNode.addEventListener('click', function(event) {
					cordova.InAppBrowser.open('http://' + that.version.ownerURL, '_blank', 'location=yes');
				});
			}
		}
	}
};
TableContentsView.prototype.showTocChapterList = function(bookCode) {
	var that = this;
	var book = this.toc.find(bookCode);
	if (book) {
		var root = document.createDocumentFragment();
		var table = that.dom.addNode(root, 'table', 'tocChap');
		var numCellPerRow = cellsPerRow();
		var numRows = Math.ceil(book.lastChapter / numCellPerRow);
		var chaptNum = 1;
		for (var r=0; r<numRows; r++) {
			var row = document.createElement('tr');
			table.appendChild(row);
			for (var c=0; c<numCellPerRow && chaptNum <= book.lastChapter; c++) {
				var cell = that.dom.addNode(row, 'td', 'tocChap', chaptNum, 'toc' + bookCode + ':' + chaptNum);
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
				if (bookNode.className === 'tocBook') {
					for (var j=bookNode.children.length -1; j>=0; j--) {
						var chaptTable = bookNode.children[j];
						bookNode.removeChild(chaptTable);
					}
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

