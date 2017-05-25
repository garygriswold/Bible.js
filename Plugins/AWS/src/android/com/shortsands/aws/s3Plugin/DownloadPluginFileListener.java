package com.shortsands.aws.s3Plugin;

import android.util.Log;
import java.io.File;
/**
 * Created by garygriswold on 5/22/17.
 */

public class DownloadPluginFileListener extends AwsS3PluginListener {

    private static String TAG = "DownloadPluginFileListener";

    public DownloadPluginFileListener() {
        super();
    }

    @Override
    protected void onComplete(int id) {
        super.onComplete(id);
        this.callbackContext.success();
    }
}

