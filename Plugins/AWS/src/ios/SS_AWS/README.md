Amazon AWS Modified Code
========================

This folder contains AWS code that has been modified to fix specific problems that I had with the code.
Whenever I adopt a new version of the AWS SDK, I will need to get an updated copy of these files as well.

SS_AWSS3PreSignedURL
--------------------

These files were modified in order to force the generation of URLs that put the bucket name in the path.
This is needed for BibleApp security.

May 28, 2017, GNG

SS_AWSPresignedURL.h

	This file is unchanged from AWSPresignedURL.h
	
SS_AWSPresignedURL.m

	#imports on line 16 to 20 were commented out.
	#import "SS_AWSS3PreSignedURL.h"  was added
	#import <AWSCore/AWSCore.h>  was added
	
	lines 247 to 252 were commented out, except 250
	lines 255 to 263 were commented out, except 262
	
Bridging-Header.h

	#import "SS_AWSS3PreSignedURL.h"
	#import "SS_AWSS3TransferUtility.m"
	
SS_AWSS3TransferUtility
-----------------------

These files were modified in order to get the TransferUtility to use the PresignedURL code in the prior step

May 28, 2017, GNG

SS_AWSS3TransferUtility.h

	This file is unchanged from AWSS3TransferUtility.h
	
AWSS3TransferUtility.m
	
	Lines 16 to 19 were changed
	#import "SS_AWSS3TransferUtility.h" was changed from #import "AWSS3TransferUtility.h"
	#import "SS_AWSS3PreSignedURL.h" was changed from #import "AWSS3PreSignedURL.h"
	//#import "AWSSynchronizedMutableDictionary.h" was removed
	#import <AWSCore/AWSCore.h> was added to replace the above line