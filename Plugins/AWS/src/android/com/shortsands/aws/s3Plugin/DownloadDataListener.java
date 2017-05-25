package com.shortsands.aws.s3;

import android.util.Log;
/**
 * Created by garygriswold on 5/22/17.
 */

public class DownloadDataListener extends AwsS3AbstractListener {

    private static String TAG = "DownloadDataListener";

    public byte[] results = null;

    public DownloadDataListener() {
        super();
    }

    @Override
    protected void onComplete(int id) {
        super.onComplete(id);
        this.results = FileManager.readBinaryFully(this.file);
        try { this.file.delete(); } catch(Exception e) {}
        Log.d(TAG, "Received: " + this.results);
    }
}
