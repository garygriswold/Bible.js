/**
* This is a test harness for unit testing the drawing of icons
*/
function iconsTest() {

	var questionsBtn = document.createElement('div');
	document.body.appendChild(questionsBtn);
	var questionsIcon = drawQuestionsIcon(200, '#777777');
	questionsBtn.appendChild(questionsIcon);
}

