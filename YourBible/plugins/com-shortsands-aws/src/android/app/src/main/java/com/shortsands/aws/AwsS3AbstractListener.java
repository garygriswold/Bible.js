package com.shortsands.aws;

import android.app.Activity;
import android.util.Log;
import com.amazonaws.mobileconnectors.s3.transferutility.TransferListener;
import com.amazonaws.mobileconnectors.s3.transferutility.TransferState;

import java.io.File;

/**
 * Created by garygriswold on 5/22/17.
 */

public class AwsS3AbstractListener implements TransferListener {

    static String TAG = "AwsS3AbstractListener";
    protected File file;
    private ProgressCircle progressCircle = null;

    public AwsS3AbstractListener() {
    }
    public void setFile(File file) {
        this.file = file;
    }
    public void setActivity(Activity activity) {
        this.progressCircle = new ProgressCircle(activity);
    }
    public void onProgressChanged(int id, long bytesCurrent, long bytesTotal) {
        Log.d(TAG, "onProgress " + Integer.toString(id) + "  " + bytesCurrent + "  " + bytesTotal + "  " + System.currentTimeMillis());
        if (this.progressCircle != null) {
            this.progressCircle.setProgress(bytesCurrent, bytesTotal);
        }
    }
    public void onStateChanged(int id, TransferState state) {
        Log.d(TAG, "onStateChanged " + id + "  TransferState " + state);
        if (state == TransferState.COMPLETED) {
            onComplete(id);
        }
        else if (state == TransferState.CANCELED) {
            // if something is canceled will onError or completed be called?
            // if not then call it here.
        }
    }
    public void onError(int id, Exception e) {
        Log.e(TAG, "Error: " + e.toString() + " on " + this.file.getAbsolutePath());
        removeProgressCircle();
    }
    protected void onComplete(int id) {
        Log.d(TAG, "Success: " + this.file.getAbsolutePath());
        removeProgressCircle();
    }
    private void removeProgressCircle() {
        if (this.progressCircle != null) {
            this.progressCircle.remove();
            this.progressCircle = null;
        }
    }
}
