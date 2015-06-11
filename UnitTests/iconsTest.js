/**
* This is a test harness for unit testing the drawing of icons
*/
function iconsTest() {
	var layoutStyle = 'display: inline-block; border: solid';

	var sendBtn = document.createElement('div');
	sendBtn.setAttribute('style', layoutStyle);
	document.body.appendChild(sendBtn);
	var sendIcon = drawSendIcon(200, '#777777');
	sendBtn.appendChild(sendIcon);

	var questionsBtn = document.createElement('div');
	questionsBtn.setAttribute('style', layoutStyle);
	document.body.appendChild(questionsBtn);
	var questionsIcon = drawQuestionsIcon(200, '#777777');
	questionsBtn.appendChild(questionsIcon);
}

