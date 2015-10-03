"use strict";

var viewLibrary = {};

viewLibrary['queueView'] = '<div id="queueView">' +
	'<!-- <p class="queue">Unassigned Questions</p>' +
	'<table class="queue">' +
	'<tr class="queue">' +
	'<th class="queue" colspan="3">KJV</th>' +
	'</tr>' +
	'<tr class="queue">' +
	'<th class="queue" style="width:33%">Unanswered Questions</th>' +
	'<th class="queue" style="width:33%">Oldest Question</th>' +
	'<th class="queue" style="width:33%">Waiting Minutes</th>' +
	'</tr>' +
	'<tr class="queue">' +
	'<td class="queue">23</td>' +
	'<td class="queue">Sept 23, 2015 13:23</td>' +
	'<td class="queue">234</td>' +
	'</tr>' +
	'<tr class="queue">' +
	'<td class="queue" colspan="3"><button id="assignKJV" class="button bigrounded blue" onclick="assignQuestion()">Assign Me A Question</button></td>' +
	'</tr>' +
	'</table> -->' +
	'</div>' +
	'<style>' +
	'table.queue {' +
	'width: 80%;' +
	'background: white;' +
	'margin: 30px auto;' +
	'}' +
	'th.queue {' +
	'border: solid;' +
	'font-family: sans-serif;' +
	'font-size: medium;' +
	'color: grey;' +
	'color: #6D929B;' +
	'border-right: 1px solid #C1DAD7;' +
	'border-bottom: 1px solid #C1DAD7;' +
	'border-top: 1px solid #C1DAD7;' +
	'letter-spacing: 2px;' +
	'text-transform: uppercase;' +
	'text-align: center;' +
	'padding: 6px 6px 6px 12px;' +
	'background: #CAE8EA' +
	'}' +
	'td.queue {' +
	'border: solid;' +
	'border-right: 1px solid #C1DAD7;' +
	'border-bottom: 1px solid #C1DAD7;' +
	'background: #ffffff;' +
	'padding: 6px 6px 6px 12px;' +
	'color: #6D929B;' +
	'font-family: sans-serif;' +
	'font-size: large;' +
	'text-align: center;' +
	'}' +
	'p.queue {' +
	'font-family: sans-serif;' +
	'text-transform: uppercase;' +
	'letter-spacing: 2px;' +
	'font-size: x-large;' +
	'color: #6D929B;' +
	'text-align: center;' +
	'}' +
	'</style>';

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
	'<p class="fieldBorder" style="margin-top: 1px">' +
	'<input id="passPhraseNode" class="inputField" type="text" placeholder="Pass Phrase" size="30" style="font-size: large">' +
	'<input type="button" class="goButton" value="Go" onclick="processPassPhrase()">' +
	'</p>' +
	'</td>' +
	'<td></td>' +
	'<tr style="height: 33%">' +
	'<td></td>' +
	'<td style="text-align: center; font-size: 0.8rem; vertical-align: top; color: white;"><span id="loginResponse">' +
	'Enter the Pass Phrase that was given to you to login.<br/>You need to do this only once for each device you use.' +
	'</span></td>' +
	'<td></td>' +
	'</tr>' +
	'</table>';

viewLibrary['headerView'] = '<table id="headerView" style="height: 15%; width: 100%; background: radial-gradient(at top right, rgba(255, 255, 0, 0.8), #006bff, rgba(3, 47, 167, 0.83), #009970, #148000)">' +
	'<tr style="height: 100%"><td style="text-align: center; vertical-align: middle; color: white">My Bible Q & A</td><tr>' +
	'</table>';

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