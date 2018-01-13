package plugin;

import android.util.Log;

import com.shortsands.aws.AwsS3;

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

	@Override
	public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
		if (action.equals("initializeRegion")) {
			String regionName = args.getString(0);
			Log.d(TAG, "regionName input = " + regionName);
			//Region region = RegionUtils.getRegion(regionName);
			if (regionName == null) {
				AwsS3.initialize("us-east-1", this.cordova.getActivity());
				//this.awsS3 = new AwsS3(this.cordova.getActivity(), Region.getRegion(Regions.US_EAST_1));
				callbackContext.error("Unknown region: " + regionName);
			} else {
				//this.awsS3 = new AwsS3(this.cordova.getActivity(), region);
				AwsS3.initialize(regionName, this.cordova.getActivity());
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
			String response = AwsS3.shared().echo3(msg);
			callbackContext.success(response);
		}	
	    else if (action.equals("preSignedUrlGET")) {
	        String s3Bucket = args.getString(0);
	        String s3Key = args.getString(1);
	        int expires = args.getInt(2);
	        URL url = AwsS3.shared().preSignedUrlGET(s3Bucket, s3Key, expires);
	        callbackContext.success(url.toExternalForm());
	        return true;
	    }
	    else if (action.equals("preSignedUrlPUT")) {
	        String s3Bucket = args.getString(0);
	        String s3Key = args.getString(1);
	        int expires = args.getInt(2);
	        String contentType = args.getString(3);
	        URL url = AwsS3.shared().preSignedUrlPUT(s3Bucket, s3Key, expires, contentType);
			callbackContext.success(url.toExternalForm());
	        return true;
		}
		else if (action.equals("downloadText")) {
			String s3Bucket = args.getString(0);
			String s3Key = args.getString(1);
			DownloadPluginTextListener listener = new DownloadPluginTextListener(callbackContext);
			AwsS3.shared().downloadText(s3Bucket, s3Key, listener);
			return true;
		}
		else if (action.equals("downloadData")) {
			String s3Bucket = args.getString(0);
			String s3Key = args.getString(1);
			DownloadPluginDataListener listener = new DownloadPluginDataListener(callbackContext);
			AwsS3.shared().downloadData(s3Bucket, s3Key, listener);
			return true;			
		}
		else if (action.equals("downloadFile")) {
			String s3Bucket = args.getString(0);
			String s3Key = args.getString(1);
			String filePath = args.getString(2);
			File file = new File(cordova.getActivity().getFilesDir(), filePath);
			DownloadPluginFileListener listener = new DownloadPluginFileListener(callbackContext);
			AwsS3.shared().downloadFile(s3Bucket, s3Key, file, listener);
			return true;			
		}
		else if (action.equals("downloadZipFile")) {
			String s3Bucket = args.getString(0);
			String s3Key = args.getString(1);
			String filePath = args.getString(2);
			File file = new File(cordova.getActivity().getFilesDir(), filePath);
			DownloadPluginZipFileListener listener = new DownloadPluginZipFileListener(callbackContext);
			AwsS3.shared().downloadZipFile(s3Bucket, s3Key, file, listener);
			return true;			
		}
		else if (action.equals("uploadAnalytics")) {
			String sessionId = args.getString(0);
			String timestamp = args.getString(1);
			String prefix = args.getString(2);
			String data = args.getString(3);
			UploadPluginDataListener listener = new UploadPluginDataListener(callbackContext);
			AwsS3.shared().uploadAnalytics(sessionId, timestamp, prefix, data, listener);
			return true;
		}
		else if (action.equals("uploadText")) {
			String s3Bucket = args.getString(0);
			String s3Key = args.getString(1);
			String data = args.getString(2);
			String contentType = args.getString(3);
			UploadPluginDataListener listener = new UploadPluginDataListener(callbackContext);
			AwsS3.shared().uploadText(s3Bucket, s3Key, data, contentType, listener);
			return true;			
		}
		else if (action.equals("uploadData")) {
			String s3Bucket = args.getString(0);
			String s3Key = args.getString(1);
			//String data = args.getString(2); //// get what????
			byte[] data = new byte[0];
			String contentType = args.getString(3);
			UploadPluginDataListener listener = new UploadPluginDataListener(callbackContext);
			AwsS3.shared().uploadData(s3Bucket, s3Key, data, contentType, listener);
			return true;			
		}
		else if (action.equals("uploadFile")) {
			String s3Bucket = args.getString(0);
			String s3Key = args.getString(1);
			String filePath = args.getString(2);
			String contentType = args.getString(3);
			File file = new File(cordova.getActivity().getFilesDir(), filePath);
			UploadPluginFileListener listener = new UploadPluginFileListener(callbackContext);
			AwsS3.shared().uploadFile(s3Bucket, s3Key, file, contentType, listener);
			return true;			
		}
	    return false;
	}
}
