package com.shortsands.aws.s3Plugin;

import android.util.Log;

import com.amazonaws.regions.Region;
import com.amazonaws.regions.Regions;
import com.amazonaws.regions.RegionUtils;

import com.shortsands.io.Zip;
import com.shortsands.aws.s3.AwsS3;

import java.io.File;
import java.net.URL;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CordovaWebView;

import org.json.JSONArray;
import org.json.JSONException;

/**
* This class echoes a string called from JavaScript.
*/
public class AWS extends CordovaPlugin {
	
	private static String TAG = "AWS";
	
	private AwsS3 awsS3;
	
	@Override
	public void initialize(CordovaInterface cordova, CordovaWebView webView) {
    	super.initialize(cordova, webView);
	}

	@Override
	public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
		if (action.equals("initializeRegion")) {
			String regionName = args.getString(0);
			Log.d(TAG, "regionName input = " + regionName);
			Region region = RegionUtils.getRegion(regionName);
			if (region == null) {
				this.awsS3 = new AwsS3(this.cordova.getActivity(), Region.getRegion(Regions.US_EAST_1));
				callbackContext.error("Unknown region: " + regionName);
			} else {
				this.awsS3 = new AwsS3(this.cordova.getActivity(), region);
				callbackContext.success();
			}
	        return true;
		}
		else if (action.equals("echo2")) {
			String msg = args.getString(0);
			callbackContext.success(msg);
		}
		else if (action.equals("echo3")) {
			String msg = args.getString(0);
			String response = this.awsS3.echo3(msg);
			callbackContext.success(response);
		}	
	    else if (action.equals("preSignedUrlGET")) {
	        String s3Bucket = args.getString(0);
	        String s3Key = args.getString(1);
	        int expires = args.getInt(2);
	        URL url = this.awsS3.preSignedUrlGET(s3Bucket, s3Key, expires);
	        callbackContext.success(url.toExternalForm());
	        return true;
	    }
	    else if (action.equals("preSignedUrlPUT")) {
	        String s3Bucket = args.getString(0);
	        String s3Key = args.getString(1);
	        int expires = args.getInt(2);
	        String contentType = args.getString(3);
	        URL url = this.awsS3.preSignedUrlPUT(s3Bucket, s3Key, expires, contentType);
			callbackContext.success(url.toExternalForm());
	        return true;
		}
		else if (action.equals("downloadText")) {
			String s3Bucket = args.getString(0);
			String s3Key = args.getString(1);
			DownloadPluginTextListener listener = new DownloadPluginTextListener(callbackContext);
			this.awsS3.downloadText(s3Bucket, s3Key, listener);
			return true;
		}
		else if (action.equals("downloadData")) {
			String s3Bucket = args.getString(0);
			String s3Key = args.getString(1);
			DownloadPluginDataListener listener = new DownloadPluginDataListener(callbackContext);
			this.awsS3.downloadData(s3Bucket, s3Key, listener);
			return true;			
		}
		else if (action.equals("downloadFile")) {
			String s3Bucket = args.getString(0);
			String s3Key = args.getString(1);
			String filePath = args.getString(2);
			File file = new File(cordova.getActivity().getFilesDir(), filePath);
			DownloadPluginFileListener listener = new DownloadPluginFileListener(callbackContext);
			this.awsS3.downloadFile(s3Bucket, s3Key, file, listener);
			return true;			
		}
		else if (action.equals("downloadZipFile")) {
			String s3Bucket = args.getString(0);
			String s3Key = args.getString(1);
			String filePath = args.getString(2);
			File file = new File(cordova.getActivity().getFilesDir(), filePath);
			DownloadPluginZipFileListener listener = new DownloadPluginZipFileListener(callbackContext);
			this.awsS3.downloadZipFile(s3Bucket, s3Key, file, listener);
			return true;			
		}
		else if (action.equals("uploadVideoAnalytics")) {
			String sessionId = args.getString(0);
			String timestamp = args.getString(1);
			String data = args.getString(2);
			UploadPluginDataListener listener = new UploadPluginDataListener(callbackContext);
			this.awsS3.uploadVideoAnalytics(sessionId, timestamp, data, listener);
			return true;
		}
		else if (action.equals("uploadText")) {
			String s3Bucket = args.getString(0);
			String s3Key = args.getString(1);
			String data = args.getString(2);
			UploadPluginDataListener listener = new UploadPluginDataListener(callbackContext);
			this.awsS3.uploadText(s3Bucket, s3Key, data, listener);
			return true;			
		}
		else if (action.equals("uploadData")) {
			String s3Bucket = args.getString(0);
			String s3Key = args.getString(1);
			//String data = args.getString(2); //// get what????
			byte[] data = new byte[0];
			UploadPluginDataListener listener = new UploadPluginDataListener(callbackContext);
			this.awsS3.uploadData(s3Bucket, s3Key, data, listener);
			return true;			
		}
		else if (action.equals("uploadFile")) {
			String s3Bucket = args.getString(0);
			String s3Key = args.getString(1);
			String filePath = args.getString(2);
			File file = new File(cordova.getActivity().getFilesDir(), filePath);
			UploadPluginFileListener listener = new UploadPluginFileListener(callbackContext);
			this.awsS3.uploadFile(s3Bucket, s3Key, file, listener);
			return true;			
		}
		else if (action.equals("zip")) {
			String sourcePath = args.getString(0);
			String targetDir = args.getString(1);
			final File source = new File(cordova.getActivity().getFilesDir(), sourcePath);
			final File target = new File(cordova.getActivity().getFilesDir(), targetDir);
			final CallbackContext ctx = callbackContext;
			cordova.getThreadPool().execute(new Runnable() {
            	public void run() {
	            	try {
	            		Zip.zip(source, target);
						ctx.success();
					} catch(Exception error) {
						ctx.error("Error in AWS.zip " + error.toString());
					}
            	}
        	});
			return true;
		}
		else if (action.equals("unzip")) {
			String sourcePath = args.getString(0);
			String targetDir = args.getString(1);
			final File source = new File(cordova.getActivity().getFilesDir(), sourcePath);
			final File target = new File(cordova.getActivity().getFilesDir(), targetDir);
			final CallbackContext ctx = callbackContext;
			cordova.getThreadPool().execute(new Runnable() {
            	public void run() {
	            	try {
	            		Zip.unzip(source, target);
						ctx.success();
					} catch(Exception error) {
						ctx.error("Error in AWS.unzip " + error.toString());
					}
            	}
        	});
			return true;
		}
	    return false;
	}
}
