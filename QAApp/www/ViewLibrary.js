var viewLibrary = {};

viewLibrary['forgotView'] = '<table id="forgotView" style="height: 100%; width: 100%; font-family: helvetica, sans-serif; background: radial-gradient(at top right, rgba(255, 255, 0, 0.8), #006bff, rgba(3, 47, 167, 0.83), #009970, #148000)">' +
	'<tr style="height: 33%">' +
	'<td style="width: 25%"></td>' +
	'<td style="width: 50%; text-align: center; vertical-align: bottom">' +
	'<p style="font-family: Avenir-Light; font-size: 1.5rem; color: #f9fbfc">Forgot Username or Password?<br> Enter your email to get started.</p>' +
	'</td>' +
	'<td style="width: 25%"></td>' +
	'</tr>' +
	'<tr style="height: 34%">' +
	'<td></td>' +
	'<td id="loginForm" style="text-align: center; vertical-align: middle;">' +
	'<p class="fieldBorder">' +
	'<input class="inputField" type="text" placeholder="Email Address" size="24" style="font-size: large">' +
	'<input type="button" class="goButton" value="Go">' +
	'</p>' +
	'</td>' +
	'<td></td>' +
	'<tr style="height: 33%">' +
	'<td></td>' +
	'<td style="text-align: center; font-size: 0.8rem; vertical-align: top;">' +
	'<span id="forgotResponse">' +
	'<a onclick="transitionBackToLoginView()" style="color:#f1f4b2;">Did you remember your password?</a>' +
	'</span></td>' +
	'<td></td>' +
	'</tr>' +
	'</table>';

viewLibrary['answerView'] = '<div id="answerView" style="height: 100%; width: 100%; background: white">' +
	'<div style="height: 90%; width: 100%;">' +
	'<div style="height: 100%; width: 50%; float: left">' +
	'<table style="height: 40%; width: 100%">' +
	'<tr class="fieldRow">' +
	'<td class="labelCell">Reference</td>' +
	'<td class="valueCell"><input id="displayReference" type="text" value="C" readonly></input></td>' +
	'</tr>' +
	'<tr class="fieldRow">' +
	'<td class="labelCell">Submitted</td>' +
	'<td class="valueCell"><input id="submittedDt" type="text" value="D" readonly></input></td>' +
	'</tr>' +
	'<tr class="fieldRow">' +
	'<td class="labelCell">Expires</td>' +
	'<td class="valueCell"><input id="expiresDesc" type="text" value="E" readonly></input></td>' +
	'</tr>' +
	'</table>' +
	'<div style="height: 60%; width: 100%; padding-left: 2%; padding-right: 2%; padding-bottom: 2%; border: none">' +
	'<span>Student Question</span>' +
	'<textarea id="question" style="width:100%; height:90%" readonly></textarea>' +
	'</div>' +
	'</div>' +
	'<div style="height: 100%; width: 50%; float: right; overflow: hidden; padding-left: 2%; padding-right: 2%; padding-bottom: 2.5%; border: none">' +
	'<span>Your Answer</span>' +
	'<textarea id="answer"></textarea>' +
	'</div>' +
	'</div>' +
	'<div style="height: 10%; width: 100%; text-align: center; padding-top: 10px">' +
	'<button class="button bigrounded blue" style="margin-right: 2%;" onclick="returnQuestion()">Return Unanswered</button>' +
	'<button class="button bigrounded blue" style="margin-right: 2%;" onclick="anotherQuestion()">Different Question</button>' +
	'<button class="button bigrounded blue" style="margin-right: 2%;" onclick="saveDraft()">Save Draft Answer</button>' +
	'<button class="button bigrounded blue" style="margin-right: 2%;" onclick="sendAnswer()">Send Answer</button>' +
	'</div>' +
	'</div>' +
	'<style type="text/css">' +
	'html, *, *:before, *:after {' +
	'-moz-box-sizing: border-box;' +
	'-webkit-box-sizing: border-box;' +
	'box-sizing: border-box;' +
	'}' +
	'.fieldRow {' +
	'width: 100%;' +
	'height: 25%;' +
	'}' +
	'.labelCell {' +
	'width: 30%;' +
	'text-align: right;' +
	'font-family: sans-serif;' +
	'font-size: 0.8rem;' +
	'color: gray;' +
	'}' +
	'.valueCell {' +
	'width: 60%;' +
	'}' +
	'input {' +
	'width: 95%;' +
	'height: 100%;' +
	'background: #f7e0b6;' +
	'border: none;' +
	'padding: 10px;' +
	'font-size: 0.9em;' +
	'}' +
	'span {' +
	'font-family: sans-serif;' +
	'font-size: 0.9rem;' +
	'color: gray;' +
	'}' +
	'textarea {' +
	'font-family: sans-serif;' +
	'font-size: 0.9rem;' +
	'background: #f7e0b6;' +
	'border: none;' +
	'}' +
	'textarea#answer {' +
	'width: 100%;' +
	'height: 100%;' +
	'background: rgba(0, 198, 238, 0.49);' +
	'border: solid thin;' +
	'}' +
	'</style>';

viewLibrary['rolesView'] = '<h1 style="text-align: center">Manage Roles</h1>' +
	'<table id="rolesView" style="width: 90%; font-family: helvetica, sans-serif; background: radial-gradient(at top right, rgba(255, 255, 0, 0.8), #006bff, rgba(3, 47, 167, 0.83), #009970, #148000);">' +
	'<tr><th colspan="3">Person</th><th colspan="5">Role</th></tr>' +
	'<tr><th>&nbsp;</th><th>Fullname</th><th>Pseudonym</th><th>Position</th><th>Version</th><th>Started</th><th>Count</th><th>&nbsp</th></tr>' +
	'<tbody id="rolesBody">' +
	'<tr>' +
	'<td>&nbsp;</td>' +
	'<td>Bob Smith</td>' +
	'<td>Bob</td>' +
	'<td>Teacher</td>' +
	'<td>KVJ</td>' +
	'<td>3/3/2013</td>' +
	'<td>20</td>' +
	'<td>&nbsp;</td>' +
	'</tr>' +
	'</tbody>' +
	'</table>';

viewLibrary['loginView'] = '<table id="loginView" style="height: 100%; width: 100%; font-family: helvetica, sans-serif; background: radial-gradient(at top right, rgba(255, 255, 0, 0.8), #006bff, rgba(3, 47, 167, 0.83), #009970, #148000);">' +
	'<tr style="height: 33%">' +
	'<td style="width: 25%"></td>' +
	'<td style="width: 50%; text-align: center; vertical-align: bottom">' +
	'<p style="font-family: Avenir-Light; font-size: 1.5rem; color: #f9fbfc">Sign-In to My Bible Q & A</p>' +
	'</td>' +
	'<td style="width: 25%"></td>' +
	'</tr>' +
	'<tr style="height: 34%">' +
	'<td></td>' +
	'<td id="loginForm" style="text-align: center; vertical-align: middle;">' +
	'<p class="fieldBorder" style="margin-bottom: 1px">' +
	'<input class="inputField" type="text" placeholder="Username" size="20" style="font-size: large">' +
	'</p>' +
	'<p class="fieldBorder" style="margin-top: 1px">' +
	'<input class="inputField" type="password" placeholder="Password" size="17" style="font-size: large">' +
	'<input type="button" class="goButton" value="Go" onclick="openQuestionCount()">' +
	'</p>' +
	'</td>' +
	'<td></td>' +
	'<tr style="height: 33%">' +
	'<td></td>' +
	'<td style="text-align: center; font-size: 0.8rem; vertical-align: top;"><span id="loginResponse">' +
	'<a onclick="transitionToForgotView()" style="color:#f1f4b2;">Did you forgot your Username or Password?</a>' +
	'</span></td>' +
	'<td></td>' +
	'</tr>' +
	'</table>';

viewLibrary['headerView'] = '<table id="headerView" style="height: 15%; width: 100%; background: radial-gradient(at top right, rgba(255, 255, 0, 0.8), #006bff, rgba(3, 47, 167, 0.83), #009970, #148000)">' +
	'<tr style="height: 100%"><td style="text-align: center; vertical-align: middle; color: white">My Bible Q & A</td><tr>' +
	'</table>';

viewLibrary['queueView'] = '<table id="queueView" style="height: 100%; width: 100%; background: white">' +
	'<tr style="height: 25%">' +
	'</tr>' +
	'<tr style="height: 5%">' +
	'<td style="width: 20%"></td>' +
	'<td style="width: 60%"><p id="numQuestions" class="queueText">num</p></td>' +
	'<td style="width: 20%"></td>' +
	'</tr>' +
	'<tr style="height: 5%">' +
	'<td></td>' +
	'<td><p id="oldestQuestion" class="queueText">oldest</p></td>' +
	'<td></td>' +
	'</tr>' +
	'<tr style="height: 5%">' +
	'<td></td>' +
	'<td><p id="waitTime" class="queueText">wait</p></td>' +
	'<td></td>' +
	'</tr>' +
	'<tr style="height: 60%">' +
	'<td></td>' +
	'<td style="text-align: center"><button id="assign" class="button bigrounded blue" onclick="assignQuestion()">Assign Me A Question</button></td>' +
	'<td></td>' +
	'</tr>' +
	'</table>' +
	'<style type="text/css">' +
	'p.queueText {' +
	'font-family: sans-serif;' +
	'font-size: large;' +
	'color: grey;' +
	'}' +
	'</style>';