package com.shortsands.aws;

import android.util.Log;
import java.io.File;
import java.io.IOException;
import java.util.List;
import com.shortsands.io.FileManager;
import com.shortsands.io.Zip;
/**
 * Created by garygriswold on 5/22/17.
 */

/**
 * This class has been deprecated, but is left here intact in case this feature is
 * reimplemented.  See PKZip/README for more info.
 */

public class DownloadZipFileListener extends AwsS3AbstractListener {

    private static String TAG = "DownloadZipFileListener";

    public File results = null;
    private File unzipped = null;


    public DownloadZipFileListener() {
        super();
    }

    public void setZipFile(File zipFile) {
        this.unzipped = this.file; // This will be the final result file.
        this.file = zipFile; // this will be the downloaded file.
    }
    @Override
    protected void onComplete(int id) {
        super.onComplete(id);
        File tmpUnzipped = null;
        try {
            Log.d(TAG, "download size " + this.file.length());
            File tmpDir = this.file.getParentFile();
            Log.d(TAG, "Unzip to " + tmpDir.getAbsolutePath());
            List<File> unzipResults = Zip.unzipFile(this.file, tmpDir);
            if (unzipResults.size() >= 1) {
                tmpUnzipped = unzipResults.get(0);
                Log.d(TAG, "Find file to move " + tmpUnzipped.length() + "  " + tmpUnzipped.getAbsolutePath());
                if (this.unzipped.getAbsolutePath().indexOf("storage") > -1) { // hack test for external
                    FileManager.copy(tmpUnzipped, this.unzipped);
                } else {
                    tmpUnzipped.renameTo(this.unzipped);
                }
                this.results = this.unzipped;
                Log.d(TAG, "Success: " + this.results.length() + "  " + this.results.getAbsolutePath());
            } else {
                onError(id, new IOException("No results from unzip after download."));
            }
        } catch (Exception err) {
            Log.e(TAG, "Error in DownloadZipFileListener " + err.toString());
            onError(id, err);
        } finally {
            if (this.file != null) try { this.file.delete(); } catch(Exception e) {}
            if (tmpUnzipped != null) try { tmpUnzipped.delete(); } catch(Exception e) {}
        }
    }
}

