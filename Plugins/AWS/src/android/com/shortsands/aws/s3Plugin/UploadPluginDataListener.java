package com.shortsands.aws.s3Plugin;

import android.util.Log;
import java.io.File;
/**
 * Created by garygriswold on 5/22/17.
 */

public class UploadPluginDataListener extends AwsS3PluginListener {

    private static String TAG = "UploadPluginDataListener";

    public UploadPluginDataListener() {
        super();
    }

    @Override
    protected void onComplete(int id) {
        super.onComplete(id);
        if (this.file != null) try { this.file.delete(); } catch(Exception e) {}
        this.callbackContext.success();
    }
}

