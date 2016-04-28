/**
* This is a helper class to remove the repetitive operations needed
* to dynamically create DOM objects.
*/
function DOMBuilder() {
	//this.rootNode = root;
}
DOMBuilder.prototype.addNode = function(parent, type, clas, content, id) {
	var node = document.createElement(type);
	if (id) node.setAttribute('id', id);
	if (clas) node.setAttribute('class', clas);
	if (content) node.textContent = content;
	parent.appendChild(node);
	return(node);
};
