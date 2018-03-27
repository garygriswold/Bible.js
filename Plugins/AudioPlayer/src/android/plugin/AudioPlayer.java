package plugin;

import android.util.Log;

import com.shortsands.audioplayer.AudioBibleController;

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

	@Override
	public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
     	AudioBibleController audioController = AudioBibleController.shared(this.cordova.getActivity());

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
            audioController.present(bookId, chapterNum);
            // This could be present(this.webView, bookId, chapterNum);
            // How do I know when the present is done?
            callbackContext.success("");
			return true;
		}
		else if (action.equals("stop")) {
            audioController.stop();
            callbackContext.success("");
			return true;
		}
	    return false;
	}
}