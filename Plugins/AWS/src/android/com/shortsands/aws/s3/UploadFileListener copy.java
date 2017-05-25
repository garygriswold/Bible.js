package com.shortsands.aws.s3;

import android.util.Log;
import java.io.File;
/**
 * Created by garygriswold on 5/22/17.
 */

public class UploadFileListener extends AwsS3AbstractListener {

    private static String TAG = "UploadFileListener";

    public UploadFileListener(File file) {
        super();
        this.file = file;
    }
    public File getFile() {
        return this.file;
    }
    @Override
    protected void onComplete(int id) {
        super.onComplete(id);
    }
}