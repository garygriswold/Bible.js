/**
* This file contains static initializers for buttons to be presente on the role management page.
*/

var roleButtons = {};

roleButtons['register'] = 	{label:'Register New Person', action:registerPerson()};
roleButtons['name'] = 		{label:'Change Name', action:changeName()};
roleButtons['password'] =	{label:'New Pass Phrase', action:newPassPhrase()};
roleButtons['addRole'] =	{label:'Add Role', action:addRole()};
roleButtons['remRole'] =	{label:'Remove Role', action:removeRole()};
roleButtons['replace'] =	{label:'Replace Person', action:replacePerson()};
roleButtons['promote'] =	{label:'Promote Person', action:promotePerson()};
roleButtons['demote'] =		{label:'Demote Person', action:demotePerson()};
roleButtons['cancel'] = 	{label:'Cancel', action:null};

var roleButtonSets = {};

roleButtonSets['register'] = [roleButton['register']];
roleButtonSets['self'] =	[roleButton['name'], roleButton['password'], roleButton['addRole']];
roleButtonSets['member'] =	[roleButton['name'], roleButton['password'], roleButton['replace'], roleButton['promote'], roleButton['demote'], roleButton['addRole']];
roleButtonSets['role'] =	[roleButton['addRole'], roleButton['remRole']];

var roleFields = {};

roleFields['name'] = 		{type:'text', populate:fillName()};
roleFields['pseudo'] =		{type:'text', populate:fillPseudo()};
roleFields['position'] =	{type:'select', populate:fillPosition()};
roleFields['version'] = 	{type:'select', populate:fillVersion()};

