package com.shortsands.aws.s3Plugin;

import android.util.Log;
import java.io.File;
import com.shortsands.aws.s3.DownloadZipFileListener;
import com.shortsands.io.Zip;
import org.apache.cordova.CallbackContext;
/**
 * Created by garygriswold on 5/22/17.
 */

public class DownloadPluginZipFileListener extends DownloadZipFileListener {

    private static String TAG = "DownloadPluginZipFileListener";
    protected CallbackContext callbackContext;
    
    private File unzipped = null;

    public DownloadPluginZipFileListener(CallbackContext callbackContext) {
        super();
	    this.callbackContext = callbackContext;
    }

    public void setZipFile(File zipFile) {
        this.unzipped = this.file; // This will be the final result file.
        this.file = zipFile; // this will be the downloaded file.
    }
    @Override
    protected void onComplete(int id) {
        super.onComplete(id);
        //File tmpDir = null;
        //File tmpUnzipped = null;
        //try {
        //    Log.d(TAG, "download size " + this.file.length());
        //    tmpDir = this.file.getParentFile();
        //    Log.d(TAG, "Unzip to " + tmpDir.getAbsolutePath());
        //    Zip.unzip(this.file, tmpDir);
        //    tmpUnzipped = new File(tmpDir, this.file.getName());
        //    Log.d(TAG, "Find file to move " + tmpUnzipped.length() + "  " + tmpUnzipped.getAbsolutePath());
        //    if (this.unzipped.getAbsolutePath().indexOf("storage") > -1) { // hack test for external
        //        FileManager.copy(tmpUnzipped, this.unzipped);
        //    } else {
        //        tmpUnzipped.renameTo(this.unzipped);
        //    }
        //    //this.results = this.unzipped;
        //    Log.d(TAG, "Success: " + this.results.length() + "  " + this.results.getAbsolutePath());
        //} catch (Exception err) {
        //    Log.e(TAG, "Error in DownloadZipFileListener " + err.toString());
        //    this.callbackContext.error(err.toString());
        //} finally {
        //    if (this.file != null) try { this.file.delete(); } catch(Exception e) {}
        //    if (tmpUnzipped != null) try { tmpUnzipped.delete(); } catch(Exception e) {}
        //    this.callbackContext.success();
        //}
        this.callbackContext.success();
    }
    
    @Override
    public void onError(int id, Exception error) {
	    super.onError(id, error);
        this.callbackContext.error(error.toString() + " on " + this.file.getAbsolutePath());
    }    
}

