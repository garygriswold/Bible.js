package com.shortsands.aws.s3Plugin;

import android.util.Log;

/**
 * Created by garygriswold on 5/22/17.
 */

public class DownloadPluginTextListener extends AwsS3PluginListener {

    private static String TAG = "DownloadPluginTextListener";

    public DownloadPluginTextListener() {
        super();
    }

    @Override
    protected void onComplete(int id) {
        super.onComplete(id);
        String results = FileManager.readTextFully(this.file);
        try { this.file.delete(); } catch(Exception e) {}
        Log.d(TAG, "Received: " + results);
        this.callbackContext.success(results);
    }
}

