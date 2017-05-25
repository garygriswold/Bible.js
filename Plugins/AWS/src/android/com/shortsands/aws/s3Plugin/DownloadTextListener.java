package com.shortsands.aws.s3;

import android.util.Log;

/**
 * Created by garygriswold on 5/22/17.
 */

public class DownloadTextListener extends AwsS3AbstractListener {

    private static String TAG = "DownloadTextListener";

    public String results = null;

    public DownloadTextListener() {
        super();
    }

    @Override
    protected void onComplete(int id) {
        super.onComplete(id);
        this.results = FileManager.readTextFully(this.file);
        try { this.file.delete(); } catch(Exception e) {}
        Log.d(TAG, "Received: " + this.results);
    }
}

