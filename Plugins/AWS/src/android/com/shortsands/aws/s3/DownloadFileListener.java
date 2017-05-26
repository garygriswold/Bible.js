package com.shortsands.aws.s3;

import android.util.Log;
import java.io.File;
/**
 * Created by garygriswold on 5/22/17.
 */

public class DownloadFileListener extends AwsS3AbstractListener {

    private static String TAG = "DownloadFileListener";

    public File results = null;

    public DownloadFileListener() {
        super();
    }
    public File getFile() {
        return this.file;
    }

    @Override
    protected void onComplete(int id) {
        super.onComplete(id);
        this.results = this.file;
    }
}

