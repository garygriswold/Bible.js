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

Cloudfront has a hostname that specifically belongs to this account, and this is a security hole,
because an initial DNS request for the service includes the hostname.  If the App were reverse
engineered this hostname could be associated with the BibleApp. However, they would not be able
to detect what was being delivered without producing or finding SignedURLs.

S3 does not have the same problem.  Instead, the bucket name can be part of the path of the URL,
and so the entire hostname refers only to a location of the S3 service, and not the BibleApp.
So, there is no leakage of identity information when using S3.

Three buckers were created in S3 for this service using the AWS Console.

	Create bucket shortsands-cdn to hold Bibles.
	Create bucket shortsands-drop for initial log files created by S3.
	Create bucket shortsands-log for filtered log files	

Create an IAM user, which only has the privilege to getObject from shortsands-cdn
These were created using the AWS Console.

	create IAM user BibleApp.
	assign to user BibleApp read-only access to S3.
	create keys for the user BibleApp
	store these keys in ShortSands/Credentials/UsersGroups/BibleApp.js
	(the above location is not in source code control)
	
The Amazon AWS SDK was installed (https://github.com/aws/aws-sdk-js)

	cd
	npm install aws-sdk
	
Write new method in VersionAdapter to generate SignedURLs for S3 bucket shortsands-cdn
Because these signed URLs are stored in a database for later use, they were given an
expiration of 20 years.  While this means they could be replayed at anytime if found,
it also means that the BibleApp does not contain any keys.

	VersionAdapter.prototype.addS3URLSignatures
	
	http://docs.aws.amazon.com/sdk-for-javascript/v2/developer-guide
	http://docs.aws.amazon.com/AWSJavaScriptSDK/latest/AWS/S3.html
	
I also attempted to write a test program that used the SDK to perform a download,
but this resulted in a binary file that was in memory as a Buffer after download,
and it still needed to be unzipped and then stored as a file in the correct location.
These two steps were not completed.
	
In FileDownloader, write a new download method to download from S3.  In order to 
be able to get locale in the the log, a parameter X-locale is put at the beginning
of the query string.

	FileDownloader.prototype._downloadAWSS3
	http://docs.aws.amazon.com/AWSJavaScriptSDK/latest/AWS/S3.html
	
In AWS Console turn-on logging for shortsands-cdn with the repository being shortsands-drop

In Lambda create a new lambda method

	name: AWS_S3_Log_Filter
	handler: index.logHandler
	role: service-role/LogSummarizer
	trigger: object create in shortsands-drop
	
	Write a Lambda that will read log file in shortsands-drop as it is created
	Parse the log, and generate a json file of all the data that we wish to keep
	Store the json file in shortsands-log
	Delete the shortsands-drop file
	
In ShortSands project, I created a new node program in the Server directory, which
extracts all of the data in the shortsands-log directory, loads it into a sqlite
database, and deletes the shortsands-log files once they are added.

S3 Accelerated Transfer was attempted, but it does not seem to work with a bucket
name in the path position, but requires the bucket name to be in the host.  This
is a severe leak, and consequently, I will not be using Accelerated Transfer




Essential Documentation:

AWS SDK
http://docs.aws.amazon.com/sdk-for-javascript/v2/developer-guide

S3 doc
http://docs.aws.amazon.com/AWSJavaScriptSDK/latest/AWS/S3.html

S3 Log doc
http://docs.aws.amazon.com/AmazonS3/latest/dev/LogFormat.html

S3 Performance talk
https://www.youtube.com/watch?v=2DpOS0zu8O0

Other documentation and things that might be of interest:

cordova plugin
cordova plugin add https://github.com/Telerik-Verified-Plugins/Amazon-AWS --variable ACCESS_KEY=<your Access Key> --variable SECRET_KEY=<your Secret Key> --save

instructions on scaling down the aws sdk
http://docs.aws.amazon.com/sdk-for-javascript/v2/developer-guide/building-sdk-for-browsers.html








	
	