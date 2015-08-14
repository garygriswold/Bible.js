function App() {
	
}
App.prototype.hello = function() {
	var topDiv = document.createElement('div');
	body.appendChild(topDiv);
	
	var para = document.createElement('p');
	para.textContent = 'Hello World';
	topDiv.appendChild(para);	
};
var app = new App();
app.hello();
