WARNING: This document is very out-of-date and probably should be deleted.
GNG Sep 22, 2017


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








	
	