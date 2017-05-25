package com.shortsands.aws.s3Plugin;

import android.util.Log;
import java.io.File;
/**
 * Created by garygriswold on 5/22/17.
 */

public class UploadPluginFileListener extends AwsS3PluginListener {

    private static String TAG = "UploadPluginFileListener";

    public UploadPluginFileListener() {
        super();
    }
    
    @Override
    protected void onComplete(int id) {
        super.onComplete(id);
        this.callbackContext.success();
    }
}