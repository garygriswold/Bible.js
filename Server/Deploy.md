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
	scp's it to the remote server.  Un-tars it.
	
7) Login and set up service on remote server and start it

	cp /root/Server/www/ServerProd.sh /root
	svccfg import /root/Server/www/shortsands.xml
	svcadm restart shortsands
	svcs | grep shortsands
	
7) Login into remote server and tail the log.


New Relic Application Monitoring
================================

1) Install new relic npm on server

	npm install newrelic
	
2) Copy newrelic.js from node_modules to server root

	cp /root/node_modules/newrelic/newrelic.js /root/Server/www
	
3) Edit copy of newrelic.js

	set app_name to 'ShortSands'
	set license_key to key provided by New Relic
	
4) Make certain require('newrelic'); is first line of server.


New Relic Server Monitoring
===========================

1) Install nrsysmond

	pkgin update
	pkgin install nrsysmond
	vi /opt/local/etc/nrsysmond.cfg
		set license key, everything else is default 
		
2) Start monitoring

	svcadm enable pkgsrc/nrsysmond
	
3) If needed, logging is as follows:

	/var/log/newrelic/nrsysmond.log
	

Creating shortsands.xml
=======================

The shortsands.xml manifest file was created on the remote host using manifold
https://docs.joyent.com/public-cloud/instances/infrastructure/images/smartos/managing-a-smartos-instance/using-the-service-management-facility/building-manifests/building-manifests-with-manifold

