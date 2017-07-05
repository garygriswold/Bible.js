package plugin;

import android.util.Log;
import com.shortsands.aws.DownloadDataListener;
import org.apache.cordova.CallbackContext;
/**
 * Created by garygriswold on 5/22/17.
 */

public class DownloadPluginDataListener extends DownloadDataListener {

    private static String TAG = "DownloadPluginDataListener";
    protected CallbackContext callbackContext;

    public DownloadPluginDataListener(CallbackContext callbackContext) {
        super();
		this.callbackContext = callbackContext;
    }

    @Override
    protected void onComplete(int id) {
        super.onComplete(id);
        this.callbackContext.success(results);
    }
    
    @Override
    public void onError(int id, Exception error) {
	    super.onError(id, error);
        this.callbackContext.error(error.toString() + " on " + this.file.getAbsolutePath());
    }
}
