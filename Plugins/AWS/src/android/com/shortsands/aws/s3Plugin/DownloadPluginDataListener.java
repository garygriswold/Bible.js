package com.shortsands.aws.s3Plugin;

import android.util.Log;
/**
 * Created by garygriswold on 5/22/17.
 */

public class DownloadPluginDataListener extends AwsS3PluginListener {

    private static String TAG = "DownloadPluginDataListener";

    public DownloadPluginDataListener() {
        super();
    }

    @Override
    protected void onComplete(int id) {
        super.onComplete(id);
        byte[] results = FileManager.readBinaryFully(this.file);
        try { this.file.delete(); } catch(Exception e) {}
        Log.d(TAG, "Received: " + results);
        this.callbackContext.success(results);
    }
}
