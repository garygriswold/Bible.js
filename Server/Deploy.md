Server Deployment
=================

1) Selected a Server on Joyent with Node installed.

2) Customize it a bit

	svcadm disable mongodb

3) Create Directories on the server

	mkdir Server
	mkdir Server/www
	mkdir StaticRoot
	mkdir StaticRoot/book
	
4) Copy files to the server

	scp Discourse.db root@host:/root/StaticRoot
	scp *.db* root@host:/root/StaticRoot/book
	
5) Install all needed node modules

	npm install -g node-gyp   # needed for sqlite and must be -g
	npm install sqlite3
	npm install node-uuid
	npm install restify
	
6) Run script to deploy code and start server

	cd Server
	./deploy.sh
	
	The above script packages the server in server.tar, 
	scp's it to the remote server.  Un-tars it, and starts
	the server.
	
7) Login into remote server and tail the log.

New Relic Monitoring
====================

1) Install new relic npm on server

	npm install newrelic
	
2) Copy newrelic.js from node_modules to server root

	cp /root/node_modules/newrelic/newrelic.js /root/Server/www
	
3) Edit copy of newrelic.js

	set app_name to 'ShortSands'
	set license_key to key provided by New Relic
	
4) Make certain require('newrelic'); is first line of server.

