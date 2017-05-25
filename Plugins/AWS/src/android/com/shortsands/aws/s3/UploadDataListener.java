package com.shortsands.aws.s3;

import android.util.Log;
import java.io.File;
/**
 * Created by garygriswold on 5/22/17.
 */

public class UploadDataListener extends AwsS3AbstractListener {

    private static String TAG = "UploadDataListener";

    public UploadDataListener() {
        super();
    }

    @Override
    protected void onComplete(int id) {
        super.onComplete(id);
        if (this.file != null) try { this.file.delete(); } catch(Exception e) {}
    }
}

