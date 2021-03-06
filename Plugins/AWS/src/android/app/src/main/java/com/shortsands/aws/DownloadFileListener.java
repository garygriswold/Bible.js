package com.shortsands.aws;

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

    @Override
    protected void onComplete(int id) {
        super.onComplete(id);
        this.results = this.file;
    }
}

