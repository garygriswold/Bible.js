package com.shortsands.aws.s3Plugin;

import android.util.Log;
import com.shortsands.aws.s3.UploadFileListener;
import java.io.File;
import org.apache.cordova.CallbackContext;
/**
 * Created by garygriswold on 5/22/17.
 */

public class UploadPluginFileListener extends UploadFileListener {

    private static String TAG = "UploadPluginFileListener";
    protected CallbackContext callbackContext;
    
    public UploadPluginFileListener(CallbackContext callbackContext) {
        super();
	    this.callbackContext = callbackContext;
    }
    
    @Override
    protected void onComplete(int id) {
        super.onComplete(id);
        this.callbackContext.success();
    }
    
    @Override
    public void onError(int id, Exception error) {
	    super.onError(id, error);
        this.callbackContext.error(error.toString() + " on " + this.file.getAbsolutePath());
    }
}