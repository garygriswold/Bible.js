package com.shortsands.aws.s3Plugin;

import android.util.Log;

import com.amazonaws.mobileconnectors.s3.transferutility.TransferListener;
import com.amazonaws.mobileconnectors.s3.transferutility.TransferState;

import java.io.File;

import org.apache.cordova.CallbackContext;

/**
 * Created by garygriswold on 5/22/17.
 */

public class AwsS3PluginListener extends AwsS3AbstractListener {

    static String TAG = "AwsS3PluginListener";
    protected CallbackContent callbackContext;

    public AwsS3PluginListener(CallbackContext callbackContext) {
	    super();
	    this.callbackContext = callbackContext;
    }
    public void setFile(File file) {
        this.file = file;
    }
    public void onError(int id, Exception e) {
        Log.e(TAG, "Error: " + e.toString() + " on " + this.file.getAbsolutePath());
        this.callbackContext.error(e.toString() + " on " + this.file.getAbsolutePath());
        
    }
}


