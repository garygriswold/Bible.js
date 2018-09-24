package plugin;

import android.util.Log;

import com.shortsands.aws.AwsS3Manager;

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
			AwsS3Manager.initialize(this.cordova.getActivity());
			callbackContext.success();
			//}
	        return true;
		}
		else if (action.equals("echo2")) {
			String msg = args.getString(0);
			callbackContext.success(msg);
		}
		else if (action.equals("echo3")) {
			String msg = args.getString(0);
			String response = AwsS3Manager.findSS().echo3(msg);
			callbackContext.success(response);
		}	
	    else if (action.equals("preSignedUrlGET")) {
	        String s3Bucket = args.getString(0);
	        String s3Key = args.getString(1);
	        int expires = args.getInt(2);
	        URL url = AwsS3Manager.findSS().preSignedUrlGET(s3Bucket, s3Key, expires);
	        callbackContext.success(url.toExternalForm());
	        return true;
	    }
	    else if (action.equals("preSignedUrlPUT")) {
	        String s3Bucket = args.getString(0);
	        String s3Key = args.getString(1);
	        int expires = args.getInt(2);
	        String contentType = args.getString(3);
	        URL url = AwsS3Manager.findSS().preSignedUrlPUT(s3Bucket, s3Key, expires, contentType);
			callbackContext.success(url.toExternalForm());
	        return true;
		}
		else if (action.equals("downloadText")) {
			String s3Bucket = args.getString(0);
			String s3Key = args.getString(1);
			DownloadPluginTextListener listener = new DownloadPluginTextListener(callbackContext);
			AwsS3Manager.findSS().downloadText(s3Bucket, s3Key, listener);
			return true;
		}
		else if (action.equals("downloadData")) {
			String s3Bucket = args.getString(0);
			String s3Key = args.getString(1);
			DownloadPluginDataListener listener = new DownloadPluginDataListener(callbackContext);
			AwsS3Manager.findSS().downloadData(s3Bucket, s3Key, listener);
			return true;			
		}
		else if (action.equals("downloadFile")) {
			String s3Bucket = args.getString(0);
			String s3Key = args.getString(1);
			String filePath = args.getString(2);
			File file = new File(cordova.getActivity().getDataDir(), filePath);
			DownloadPluginFileListener listener = new DownloadPluginFileListener(callbackContext);
			AwsS3Manager.findSS().downloadFile(s3Bucket, s3Key, file, listener);
			return true;			
		}
		else if (action.equals("downloadZipFile")) {
			String s3Bucket = args.getString(0);
			String s3Key = args.getString(1);
			String filePath = args.getString(2);
			File file = new File(cordova.getActivity().getDataDir(), filePath);
			DownloadPluginZipFileListener listener = new DownloadPluginZipFileListener(callbackContext);
			listener.setActivity(cordova.getActivity()); // presents ProgressCircle
			AwsS3Manager.findSS().downloadZipFile(s3Bucket, s3Key, file, listener);
			return true;			
		}
		else if (action.equals("uploadAnalytics")) {
			String sessionId = args.getString(0);
			String timestamp = args.getString(1);
			String prefix = args.getString(2);
			String data = args.getString(3);
			UploadPluginDataListener listener = new UploadPluginDataListener(callbackContext);
			AwsS3Manager.findSS().uploadAnalytics(sessionId, timestamp, prefix, data, listener);
			return true;
		}
		else if (action.equals("uploadText")) {
			String s3Bucket = args.getString(0);
			String s3Key = args.getString(1);
			String data = args.getString(2);
			String contentType = args.getString(3);
			UploadPluginDataListener listener = new UploadPluginDataListener(callbackContext);
			AwsS3Manager.findSS().uploadText(s3Bucket, s3Key, data, contentType, listener);
			return true;			
		}
		else if (action.equals("uploadData")) {
			String s3Bucket = args.getString(0);
			String s3Key = args.getString(1);
			//String data = args.getString(2); //// get what????
			byte[] data = new byte[0];
			String contentType = args.getString(3);
			UploadPluginDataListener listener = new UploadPluginDataListener(callbackContext);
			AwsS3Manager.findSS().uploadData(s3Bucket, s3Key, data, contentType, listener);
			return true;			
		}
		else if (action.equals("uploadFile")) {
			String s3Bucket = args.getString(0);
			String s3Key = args.getString(1);
			String filePath = args.getString(2);
			String contentType = args.getString(3);
			File file = new File(cordova.getActivity().getDataDir(), filePath);
			UploadPluginFileListener listener = new UploadPluginFileListener(callbackContext);
			AwsS3Manager.findSS().uploadFile(s3Bucket, s3Key, file, contentType, listener);
			return true;			
		}
	    return false;
	}
}
