package com.shortsands.aws.s3Plugin;

import android.util.Log;
import java.io.File;
import com.shortsands.io.Zip;
/**
 * Created by garygriswold on 5/22/17.
 */

public class DownloadPluginZipFileListener extends AwsS3PluginListener {

    private static String TAG = "DownloadPluginZipFileListener";

    private File unzipped = null;

////
//// ?? can this be rewritten to extend the DownloadZip...
////
    public DownloadPluginZipFileListener() {
        super();
    }

    public void setZipFile(File zipFile) {
        this.unzipped = this.file; // This will be the final result file.
        this.file = zipFile; // this will be the downloaded file.
    }
    @Override
    protected void onComplete(int id) {
        super.onComplete(id);
        File tmpDir = null;
        File tmpUnzipped = null;
        try {
            Log.d(TAG, "download size " + this.file.length());
            tmpDir = this.file.getParentFile();
            Log.d(TAG, "Unzip to " + tmpDir.getAbsolutePath());
            Zip.unzip(this.file, tmpDir);
            tmpUnzipped = new File(tmpDir, this.file.getName());
            Log.d(TAG, "Find file to move " + tmpUnzipped.length() + "  " + tmpUnzipped.getAbsolutePath());
            if (this.unzipped.getAbsolutePath().indexOf("storage") > -1) { // hack test for external
                FileManager.copy(tmpUnzipped, this.unzipped);
            } else {
                tmpUnzipped.renameTo(this.unzipped);
            }
            //this.results = this.unzipped;
            Log.d(TAG, "Success: " + this.results.length() + "  " + this.results.getAbsolutePath());
        } catch (Exception err) {
            Log.e(TAG, "Error in DownloadZipFileListener " + err.toString());
            this.callbackContext.error(err.toString());
        } finally {
            if (this.file != null) try { this.file.delete(); } catch(Exception e) {}
            if (tmpUnzipped != null) try { tmpUnzipped.delete(); } catch(Exception e) {}
            this.callbackContext.success();
        }
    }
}

