package com.shortsands.aws.s3Plugin;

import android.util.Log;
import com.shortsands.aws.s3.UploadDataListener;
import java.io.File;
import org.apache.cordova.CallbackContext;
/**
 * Created by garygriswold on 5/22/17.
 */

public class UploadPluginDataListener extends UploadDataListener {

    private static String TAG = "UploadPluginDataListener";
    protected CallbackContext callbackContext;
    
    public UploadPluginDataListener(CallbackContext callbackContext) {
        super();
	    this.callbackContext = callbackContext;
    }

    @Override
    protected void onComplete(int id) {
        super.onComplete(id);
        //if (this.file != null) try { this.file.delete(); } catch(Exception e) {}
        this.callbackContext.success();
    }
    
    @Override
    public void onError(int id, Exception error) {
	    super.onError(id, error);
        this.callbackContext.error(error.toString() + " on " + this.file.getAbsolutePath());
    }
}

