package plugin;

import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.webkit.WebView;

import com.shortsands.audioplayer.AudioBibleController;
import com.shortsands.aws.CompletionHandler;

import java.io.File;
import java.net.URL;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;

import org.json.JSONArray;
import org.json.JSONException;

/**
* This class echoes a string called from JavaScript.
*/
public class AudioPlayer extends CordovaPlugin {
	
	private static String TAG = "AudioPlayer";

	private CallbackContext callbackContext;

	@Override
	public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
     	AudioBibleController audioController = AudioBibleController.shared(this.cordova.getActivity());
		this.callbackContext = callbackContext;

        if (action.equals("findAudioVersion")) {
            String version = args.getString(0);
            String silLang = args.getString(1);
            String bookList = audioController.findAudioVersion(version, silLang);
	        callbackContext.success(bookList);
	        return true;
	    }
	    else if (action.equals("isPlaying")) {
            String message = (audioController.isPlaying()) ? "T" : "F";
			callbackContext.success(message);
	        return true;
		}
		else if (action.equals("present")) {
			String bookId = args.getString(0);
			int chapterNum = args.getInt(1);
			AudioPresentCompletion complete = new AudioPresentCompletion();
			View view = super.webView.getView();
			if (view instanceof WebView) {
				audioController.present((WebView)view, bookId, chapterNum, complete);
				return true;
			} else {
				complete.failed(new Exception("Unable to find WebView."));
				return true;
			}
		}
		else if (action.equals("stop")) {
            audioController.stop();
            callbackContext.success("");
			return true;
		}
	    return false;
	}

	class AudioPresentCompletion implements CompletionHandler {
		@Override
		public void completed(Object result) {
			callbackContext.success("");
		}
		@Override
		public void failed(Throwable exception) {
			Log.d(TAG, "NextReadFile Failed " + exception.toString());
			callbackContext.error(exception.toString());
		}
	}

	 /**
     * Called when a plugin is the recipient of an Activity result after the CordovaActivity has
     * been destroyed. The Bundle will be the same as the one the plugin returned in
     * onSaveInstanceState()
     *
     * @param state             Bundle containing the state of the plugin
     * @param callbackContext   Replacement Context to return the plugin result to
     */
    @Override
    public void onRestoreStateForActivityResult(Bundle state, CallbackContext callbackContext) {
	    Log.d(TAG, "onRestoreStateForActivityResult " + System.currentTimeMillis());
	    this.callbackContext = callbackContext;
    }
}
