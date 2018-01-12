package plugin;

import android.util.Log;

import com.shortsands.zip.PKZipper;

import java.io.File;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;

import org.json.JSONArray;
import org.json.JSONException;

/**
* This class is the Cordova plugin interface to the Zip.jar
*/
public class PKZip extends CordovaPlugin {

	@Override
	public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
		if (action.equals("echo2")) {
			String msg = args.getString(0);
			callbackContext.success(msg);
		}
		else if (action.equals("echo3")) {
			String msg = args.getString(0);
			//String response = this.awsS3.echo3(msg);
			String response = msg;
			callbackContext.success(response);
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
	            		PKZipper.zipFile(source, target);
						ctx.success();
					} catch(Exception error) {
						ctx.error("Error in PKZip.zip " + error.toString());
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
	            		PKZipper.unzipFile(source, target);
						ctx.success();
					} catch(Exception error) {
						ctx.error("Error in PKZip.unzip " + error.toString());
					}
            	}
        	});
			return true;
		}
	    return false;
	}
}
