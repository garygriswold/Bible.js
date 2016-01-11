Server Deployment
=================

1) Selected a Server on Joyent with Node installed.

	Micro 0.5 GB RAM 0.125 vCPUs 16 GB Disk
	east-2: 165.225.166.55
	east-3: 165.225.175.252

2) Customize it a bit

	svcadm disable mongodb
	
3) Install zip / unzip

	pkgin update
	pkgin install zip-3
	pkgin install unzip

4) Create Directories on the server

	mkdir Server
	mkdir Server/www
	mkdir StaticRoot
	mkdir StaticRoot/book
	
5) Copy files to the server

	scp Discourse.db root@host:/root/StaticRoot
	scp *.db* root@host:/root/StaticRoot/book
	unzip each .zip file in book.
	
6) Install all needed node modules

	npm install -g node-gyp   # needed for sqlite and must be -g
	npm install sqlite3
	npm install node-uuid
	npm install restify
	
7) Run script to deploy code and start server

	cd Server
	./deploy.sh  # modify IP address before running
	
	The above script packages the server in server.tar, 
	scp's it to the remote server.  Un-tars it.
	

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
	

Enable svcadm
=============

1) A manifest file is required for svcadm, it should be present as Server/www/shortsands.xml

2) If not present, then create as follows:

The shortsands.xml manifest file was created on the remote host using manifold
https://docs.joyent.com/public-cloud/instances/infrastructure/images/smartos/managing-a-smartos-instance/using-the-service-management-facility/building-manifests/building-manifests-with-manifold


Install Application Server
==========================
	
1) Login and set up service on remote server and start it

	cp /root/Server/www/ServerProd.sh /root
	svccfg import /root/Server/www/shortsands.xml
	svcadm restart shortsands
	svcs | grep shortsands
	
2) Execute a Curl command on the local machine

	curl -i http://165.225.175.252:8080/book/WEB.db1.zip > out.zip
	
3) Execute Unit Server Tests

	cd /BibleApp/Server/UnitTests
	vi ServerMethodTest.js   # change IP address at end of file
	./ServerMethodTest.sh
	
4)  
	
5) Login into remote server and tail the log.

Install QAApp
=============

1) From the Development Environment copy up the QAApp

	cd /BibleApp/QAApp
	vi deploy.sh   # correct the IP address
	./deploy.sh
	
2) Check that the QAApp is working

	http://IP_ADDRESS:8080
	#It should present the starting page, but might not present others because of hard-coded qa.shortsands.com


