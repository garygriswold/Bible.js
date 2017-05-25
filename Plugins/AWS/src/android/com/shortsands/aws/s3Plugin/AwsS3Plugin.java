package com.shortsands.aws;

import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CallbackContext;
import org.apache.cordova.PluginResult;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

/**
* This class echoes a string called from JavaScript.
*/
public class AWSS3 extends CordovaPlugin {
	
	private AwsS3 awsS3;
	
	@Override
	public void initialize(CordovaInterface cordova, CordovaWebView webView) {
    	super.initialize(cordova, webView);
		this.awsS3 = new AwsS3();
	}

	@Override
	public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
	    if (action.equals("preSignedUrlGET")) {
	        String s3Bucket = args.getString(0);
	        String s3Key = args.getString(1);
	        int expires = args.getInt(2);
	        URL url = this.awsS3.preSignedUrlGET(s3Bucket, s3Key, expires);
	        JSONObject obj = new JSONObject("{error: null, url: " + url.toString() + "}";
	        PluginResult result = new PluginResult(PluginResult.OK, obj);
	        callbackContext.sendPluginResult(result);
	        return true;
	    }
	    else if (action.equals("preSignedUrlPUT")) {
	        String s3Bucket = args.getString(0);
	        String s3Key = args.getString(1);
	        int expires = args.getInt(2);
	        String contentType = args.getString(3);
	        URL url = this.awsS3.preSignedUrlPUT(s3Bucket, s3Key, expires, contentType);
			JSONObject msg = new JSONObject("{error: null, url: " + url.toString() + "}";
	        PluginResult result = new PluginResult(PluginResult.OK, msg);
	        callbackContext.sendPluginResult(result);
	        return true;
		}
		else if (action.equals("zip")) {
			String sourceFile = args.getString(0);
			String targetDir = args.getString(1);
			cordova.getThreadPool().execute(new Runnable() {
            	public void run() {
	            	this.awsS3.zip(sourceFile, targetDir);
                	JSONObject msg = new JSONObject("{error: null}");
                	PluginResult result = new PluginResult.OK, msg);
                	callbackContext.sendPluginResult(result);
            	}
        	});
			return true;
		}
		else if (action.equals("unzip")) {
			String sourceFile = args.getString(0);
			String targetDir = args.getString(1);
			cordova.getThreadPool().execute(new Runnable() {
            	public void run() {
	            	this.awsS3.unzip(sourceFile, targetDir);
                	JSONObject msg = new JSONObject("{error: null}");
                	PluginResult result = new PluginResult.OK, msg);
                	callbackContext.sendPluginResult(result);
            	}
        	});
			return true;
		}
		else if (action.equals("downloadText")) {
			String s3Bucket = args.getString(0);
			String s3Key = args.getString(1);
			AwsCordovaReceiver receiver = new AwsCordovaReceiver(callbackContext);
			this.downloadText(s3Bucket, s3Key, receiver);
			return true;
		}
		else if (action.equals("downloadData")) {
			String s3Bucket = args.getString(0);
			String s3Key = args.getString(1);
			AwsCordovaReceiver receiver = new AwsCordovaReceiver(callbackContext);
			this.downloadData(s3Bucket, s3Key, receiver);
			return true;			
		}
		else if (action.equals("downloadFile")) {
			String s3Bucket = args.getString(0);
			String s3Key = args.getString(1);
			String filePath = args.getString(2);
			AwsCordovaReceiver receiver = new AwsCordovaReceiver(callbackContext);
			this.downloadFile(s3Bucket, s3Key, filePath, receiver);
			return true;			
		}
		else if (action.equals("downloadZipFile")) {
			String s3Bucket = args.getString(0);
			String s3Key = args.getString(1);
			String filePath = args.getString(2);
			AwsCordovaReceiver receiver = new AwsCordovaReceiver(callbackContext);
			this.downloadZipFile(s3Bucket, s3Key, filePath, receiver);
			return true;			
		}
		else if (action.equals("uploadAnalytics")) {
			String sessionId = args.getString(0);
			String timestamp = args.getString(1);
			AwsCordovaReceiver receiver = new AwsCordovaReceiver(callbackContext);
			this.uploadAnalytics(sessionId, timestamp, receiver);
			return true;
		}
		else if (action.equals("uploadText")) {
			String s3Bucket = args.getString(0);
			String s3Key = args.getString(1);
			String data = args.getString(2);
			AwsCordovaReceiver receiver = new AwsCordovaReceiver(callbackContext);
			this.uploadText(s3Bucket, s3Key, data, receiver);
			return true;			
		}
		else if (action.equals("uploadData")) {
			String s3Bucket = args.getString(0);
			String s3Key = args.getString(1);
			String data = args.getString(2); //// get what????
			AwsCordovaReceiver receiver = new AwsCordovaReceiver(callbackContext);
			this.uploadData(s3Bucket, s3Key, data, receiver);
			return true;			
		}
		else if (action.equals("uploadFile")) {
			String s3Bucket = args.getString(0);
			String s3Key = args.getString(1);
			String filePath = args.getString(2);
			AwsCordovaReceiver receiver = new AwsCordovaReceiver(callbackContext);
			this.uploadFile(s3Bucket, s3Key, filePath, receiver);
			return true;			
		}
	    return false;
	}
}
