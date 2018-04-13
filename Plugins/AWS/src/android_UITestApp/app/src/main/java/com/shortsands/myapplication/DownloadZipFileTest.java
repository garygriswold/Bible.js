package com.shortsands.myapplication;



/**
 * Created by garygriswold on 4/12/18.
 */

import android.app.Activity;
import com.shortsands.aws.*;

import java.io.File;
import android.util.Log;

public class DownloadZipFileTest extends DownloadZipFileListener {

    private static String TAG = "DownloadZipTest";

    long startTime = System.currentTimeMillis();

    public DownloadZipFileTest() {

    }

    public void doTest(Activity activity) {
        AwsS3.initialize("us-west-2", activity);
        this.setActivity(activity);
        File root = activity.getFilesDir();
        File file1 = new File(root, "WEB.db");
        AwsS3 s3 = AwsS3.shared();
        s3.downloadZipFile("shortsands", "WEB.db.zip", file1, this);
    }
    public void onError(int id, Exception e) {
        super.onError(id, e);
        Log.e(TAG, "Error: " + e.toString() + " on " + this.file.getAbsolutePath());
        Log.d(TAG, "RESULTS |" + this.results + "|");
    }
    protected void onComplete(int id) {
        super.onComplete(id);
        Log.d(TAG, "onComplete ID " + id + "  " + (System.currentTimeMillis() - startTime) + "ms  ");
    }
}
