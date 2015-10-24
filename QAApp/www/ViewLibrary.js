"use strict";

var viewLibrary = {};

viewLibrary.answerView = '<div id="answerView" style="height: 100%; width: 100%;">' +
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

viewLibrary.loginView = '<div style="height:100%; width:100%; background: radial-gradient(at top right, rgba(255, 255, 0, 0.8), #006bff, rgba(3, 47, 167, 0.83), #009970, #148000);">' +
	'<table id="loginView" class="login">' +
	'<tr class="login">' +
	'<td style="text-align: center; vertical-align: bottom">' +
	'<p style="font-family: Avenir-Light; font-size: 1.5rem; color: #f9fbfc">Sign-In to My Bible Q & A</p>' +
	'<p style="font-family: sans-serif; font-size:0.8rem; color:white">You must do this once for each device you own.</p>' +
	'</td>' +
	'</tr>' +
	'<tr class="belief">' +
	'<td class="belief">' +
	'<ul>' +
	'<li>I believe the Bible is inspired by God; as a result it is free from error and is the supreme authority in matters of faith.</li>' +
	'<li>I believe there is one God, creator of all, who exists eternally in three persons: Father, Son, and Holy Spirit.</li>' +
	'<li>I believe that Jesus Christ, the Son of God, is both fully human and fully God, and has lived a sinless life.</li>' +
	'<li>I believe that Jesus Christ died on the cross as a substitute for the punishment that is due all people, because of their sin.  By doing this, he has given everyone their only opportunity of eternal salvation by putting their trust in Him.</li>' +
	'<li>I believe that the Holy Spirit dwells within each person who has put their trust in Jesus Christ, and is there to teach, and help believers lead a life that is glorifying to God.</li>' +
	'<li>I believe that all, who have put their trust in Jesus Christ, without regard to religious denomination, are part of the Church.</li>' +
	'<li>I believe in the bodily resurrection of Jesus Christ three days after His death on the cross, and that all those who have placed their trust in Him will also be resurrected to eternal life with Him, and those who have not will be resurrected to judgment.</li>' +
	'</ul>' +
	'</td>' +
	'</tr>' +
	'<tr class="login">' +
	'<td id="loginForm" style="text-align: center; vertical-align: middle;">' +
	'<p class="fieldBorder" style="margin-top: 1px">' +
	'<input id="passPhraseNode" class="inputField" type="text" placeholder="Pass Phrase" size="30" style="font-size: large">' +
	'<input type="button" class="goButton" value="Go" onclick="processPassPhrase()">' +
	'</p>' +
	'</td>' +
	'<tr class="login">' +
	'<td style="text-align: center; font-size: 0.8rem; vertical-align: top; color: white;">' +
	'Enter the Pass Phrase that was given to you to express your agreement with the above statement of beliefs.' +
	'</td>' +
	'</tr>' +
	'</table>' +
	'</div>' +
	'<style>' +
	'table.login {' +
	'height:100%;' +
	'width:80%;' +
	'margin:auto;' +
	'font-family: sans-serif;' +
	'}' +
	'tr.login {' +
	'width:100%;' +
	'height:20%;' +
	'}' +
	'tr.belief {' +
	'height:40%;' +
	'}' +
	'td.belief {' +
	'font-size:1.0rem;' +
	'color:#DDDDDD;' +
	'}' +
	'</style>';

viewLibrary.queueView = '<div id="queueView" style="margin-top:30px">' +
	'<table style="width:75%; margin:auto">' +
	'<tr>' +
	'<td style="width:50%;">' +
	'<button class="button bigrounded blue" onclick="logout()">Forget Me! This Is Not My Computer</button>' +
	'</td>' +
	'<td style="width:50%; text-align:right">' +
	'<button id="manageBtn" class="button bigrounded blue" onclick="presentRoles()">Manage Roles</button>' +
	'</td>' +
	'</tr>' +
	'</table>' +
	'<p class="queue">Unassigned Questions</p>' +
	'</div>' +
	'<div id="queueTables">' +
	'<!-- <table class="queue">' +
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

viewLibrary.rolesView = '<div id="rolesView" style="width:100%; height:100%; margin:0; padding:0;">' +
	'<h1 class="role">Manage Responsibilities</h1>' +
	'<table style="width:75%; margin:auto">' +
	'<tr>' +
	'<td style="width:50%;">' +
	'<button class="button bigrounded blue" onclick="roleBackToQueue()">Back</button>' +
	'</td>' +
	'<td style="width:50%; text-align:right">' +
	'<button class="button bigrounded blue" onclick="registerNewPerson()">Register New Person</button>' +
	'</td>' +
	'</tr>' +
	'</table>' +
	'<table class="role">' +
	'<tr class="role">' +
	'<th class="role" colspan="3">Person</th>' +
	'<th class="role" colspan="5">Responsibility</th>' +
	'</tr>' +
	'<tr class="role">' +
	'<th id="it1" class="role" style="font-size:1.7rem; padding:6px; width:5%"></th>' +
	'<th class="role" style="width:30%">Fullname</th>' +
	'<th class="role" style="width:15%">Pseudonym</th>' +
	'<th class="role" style="width:15%">Position</th>' +
	'<th class="role" style="width:15%">Version</th>' +
	'<th class="role" style="width:15%">Started</th>' +
	'<th id="it2" class="role" style="font-size:1.7rem; padding:6px; width:5%"></th>' +
	'</tr>' +
	'<tbody id="rolesBody" class="role">' +
	'<!-- <tr class="role">' +
	'<td class="role"><input type="checkbox" onclick="personEdit()"></td>' +
	'<td class="role">Bob Smith</td>' +
	'<td class="role">Bob</td>' +
	'<td class="role">Teacher</td>' +
	'<td class="role">KJV</td>' +
	'<td class="role">3/3/2013</td>' +
	'<td class="role"><input type="checkbox" onclick="roleEdit()"</td>' +
	'</tr> -->' +
	'</tbody>' +
	'</table>' +
	'</div>' +
	'<style>' +
	'h1.role {' +
	'margin-top:30px;' +
	'font-family: sans-serif;' +
	'text-transform: uppercase;' +
	'letter-spacing: 2px;' +
	'font-size: x-large;' +
	'color: #6D929B;' +
	'text-align:center;' +
	'}' +
	'table.role {' +
	'width: 80%;' +
	'background: white;' +
	'margin: 30px auto;' +
	'border: none;' +
	'}' +
	'th.role {' +
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
	'background: #CAE8EA;' +
	'}' +
	'td.role {' +
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
	'td.roleHead {' +
	'border-right: 1px solid #C1DAD7;' +
	'border-bottom: 1px solid #C1DAD7;' +
	'border-top: 1px solid #C1DAD7;' +
	'background: #CAE8EA;' +
	'}' +
	'</style>' +
	'<script>' +
	'function loadPageFunction() {' +
	'var pencil = String.fromCharCode("0x270E");' +
	'var node1 = document.getElementById("it1");' +
	'node1.textContent = pencil;' +
	'var node2 = document.getElementById("it2");' +
	'node2.textContent = pencil;' +
	'}' +
	'</script>';