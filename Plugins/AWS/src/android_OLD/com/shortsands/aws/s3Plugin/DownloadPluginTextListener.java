package com.shortsands.aws.s3Plugin;

import android.util.Log;
import com.shortsands.aws.s3.DownloadTextListener;
import org.apache.cordova.CallbackContext;

/**
 * Created by garygriswold on 5/22/17.
 */

public class DownloadPluginTextListener extends DownloadTextListener {

    private static String TAG = "DownloadPluginTextListener";
    protected CallbackContext callbackContext;

    public DownloadPluginTextListener(CallbackContext callbackContext) {
        super();
	    this.callbackContext = callbackContext;
    }

    @Override
    protected void onComplete(int id) {
        super.onComplete(id);
        this.callbackContext.success(this.results);
    }
    
    @Override
    public void onError(int id, Exception error) {
	    super.onError(id, error);
        this.callbackContext.error(error.toString() + " on " + this.file.getAbsolutePath());
    }
}

