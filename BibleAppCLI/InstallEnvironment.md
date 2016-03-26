Update the Development Environment
==================================

March 26, 2016

Download Node 4.4.1
-------------------

	download from nodejs.org and run installer
	node -v 
	
Install all needed node modules
-------------------------------

	sudo npm install -g node-gyp   # needed for sqlite and must be -g
	npm install sqlite3
	npm install node-uuid
	npm install restify
