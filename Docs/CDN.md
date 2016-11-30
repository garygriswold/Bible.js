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

Amazon AWS Cloudfront
=====================

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


Amazon AWS S3 Hosting
=====================

Cloudfront has a hostname that specifically belongs to this account, and this is a security hole.
S3 does not have the same problem.  Instead, the bucket name can be part of the path of the URL.
So, it is fully encrypted over the Internet.

1. Create bucket for Bibles, shortsands-cdn copy all Bibles from shortsands.
2. Create bucket for writing logs, shortsands-drop
3. Create bucket for reprocessed logs, shortsands-log
4. Install the node aws (https://github.com/aws/aws-sdk-js)

	cd
	npm install aws-sdk
	
5. Write new method in VersionAdapter to generate URLs, if possible

	http://docs.aws.amazon.com/sdk-for-javascript/v2/developer-guide
	var S3 = require('aws-sdk/clients/s3');
	
6. Or, write test node program to make requests of the shortsands-cdn

	? Is the program making secure requests over SSL YES
	? Is the program using Digital Signature YES
	? How would this code interact with cordova.file?
	? How do I write to a file as chucks are received?
	
6aa. Create an IAM account, which only has the privilege to getObject from shortsands-cdn

	create IAM user BibleApp
	create keys for the user BibleApp
	add keys to program
	assign to BibleApp an S3 read-only policy
	verify that access succeeds
	store the keys in a file that will not be put into source code control
	
7. Write new download method in download class for s3
	
8 Need to verify that 2110947880 is unix time 20 years into the future.

9. Turn on logging of shortsands-cdn to shortsands-drop

	must include a cookie in the log
	
??????

6a. Attempt to reduce the sdk to only have the required classes

	http://docs.aws.amazon.com/sdk-for-javascript/v2/developer-guide/building-sdk-for-browsers.html

7. Install cordova aws plugin

	cordova plugin add https://github.com/Telerik-Verified-Plugins/Amazon-AWS --variable ACCESS_KEY=<your Access Key> --variable SECRET_KEY=<your Secret Key> --save
	
	check its size to verify that it is needed.
	
	If it is too large is there a way to isolate and use the required classes from aws-sdk. 
	
8. Write new download method in download class for s3




S3 doc
http://docs.aws.amazon.com/AWSJavaScriptSDK/latest/AWS/S3.html

S3 Log doc
http://docs.aws.amazon.com/AmazonS3/latest/dev/LogFormat.html

S3 Performance talk
https://www.youtube.com/watch?v=2DpOS0zu8O0








	
	