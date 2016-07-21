KeyCDN and CacheFly are services that could be used to deliver Bibles.
As of July 20, 2016, this has not yet been put into production, because the
cost of syslog forwarding is $3/day at KeyCDN and CacheFly has a minimum cost 
of $50/month.

The basic idea is that we use a push CDN to house the Bibles.  Because the CDN houses 
all kind of data it would not be immediately recognized as a Bible server and be blocked.

The request and response would also need to be encrypted so that no one could tell
what was requested and received.  A shared SSL certificate should be used so that the
hostname is not part of the domain, which will conceal that hostname part.  (This needs
verification.  For example: short1-4930.keycdn.com is the entire hostname).  Hopefully,
by using a shared certificate, SSL/TLS will recognize keycdn.com as the domain.

A secure token must be used that involves a shared secret that is on the server and
stored inside the App.  The request code would generate a URL that has a limited life.
This mechanism would replace the current digital signature method of copyright protection.

Unfortunately, these CDNs generate a log that contains the IP address of the requestor,
and in the case of keycdn it also contains latitude and longitude of that IP. (not sure about
CacheFly.)

It is necessary to process the log with two purposes.  First, it would be best if the IP address
and other similar data could be eliminated as soon as possible.  Second, we must produce a report
of country, language, version, and timestamp for each download. KeyCDN and CacheFly offer two
different solutions.

CacheFly would be able to store the log on disk where it could be downloaded.  This has
the advantage that no data would be lost.  It has a disadvantage that the IP address of the 
requestor resides in that file until it is processed and destroyed.  The file would be periodically 
downloaded to our server, processed store the required data and deleted.  CacheFly does not expect
any additional payment for this service.

KeyCDN provides log forwarding.  This has the advantage that the IP address and related data could
be filtered out as soon as it is received on the syslog server.  Doing this probably requires that
I deploy the syslog server.  It has the disadvantage that data is transmitted over UDP and could 
sometimes be lost.  It also costs $3/day to have this service.

Prices: The cost of CacheFly would be about $50/month, i.e. the minimum.  The cost of cdnkey would be
about $90/month, i.e. the cost of log forwarding.  The cost of my current shortsands.com server is
$20/month, and this would still be required with cdnkey, but not with cachefly.  For the actual delivery of
content keycdn would be about $0.04/GB and CacheFly would be about $0.10/GB depending upon location.
Amazon Cloudfront has a cost of $0.85/GB to $0.17/GB depending upon location, but I don't think there
are any minimum charges.  But, I am not sure about log services, except that it does provide a raw
log and it does also provide some other data with download without a raw log.

Amazon AWS
==========

S3
--

	Using existing username and password, logged into AWS Console.
	Created a bucket named shortsands
	Uploaded existing production Bibles in .db.zip form
	The default permission is that only I can access,
	But, temporarily change to public and it can be downloaded.
	Default content-type is application/zip, which is correct
	
Cloudfront
----------

	Establish cloudfront with connection the above S3
	Have AWS create new user and setup permissions
	Have SSL required and use a shared SSL .cloudfront.net
	URL:  d1obplp0ybf6eo.cloudfront.net
	
Secure URL
----------

	Turn on Trusted Signers
	Create Cloudfront key pair in Console
	Download and store in Credentials
	Unfortunately, there are no examples for signing it in JS.
	
URL Signing in Node
	
	npm install aws-cloudfront-sign
		aws-cloudfront-sign@2.1.2 node_modules/aws-cloudfront-sign
		└── lodash@3.10.1


KeyCDN
======

Account
-------

	The username of the account is garygriswold and the password is Br1...

Create Zone
-----------

	A push zone was created 7/18/2016 with the name short1.  The full URL is http://short1-4930.kxcdn.com
	
Upload Files
------------

	Files could be easily uploaded with Panic using a drag and drop ftp.
	
Access Files
------------

	curl http://short1-4930.kxcdn.com/WEB.db.zip > it.zip
	
SSL
---

	Turned on Shared SSL, it still works
	curl https://short1-4930.kxcdn.com/WEB.db.zip > it.zip
	
Secret Token
------------

	Using program: Certificates/keycdnToken.js
	cd ShortSands/Credentials
	node keycdnToken.js -> generates a URL such as the following.  It has a life of 120 seconds.
	curl -v https://short1-4930.kxcdn.com/NMV.db.zip?token=W8n9q3FZj0A2iKAUzhej5Q&expire=1468941954 > nmv.db.zip
	curl -v http://short1-4930.kxcdn.com/NMV.db.zip?token=W8n9q3FZj0A2iKAUzhej5Q&expire=1468941954 > nmv.db.zip
	
	


	
	