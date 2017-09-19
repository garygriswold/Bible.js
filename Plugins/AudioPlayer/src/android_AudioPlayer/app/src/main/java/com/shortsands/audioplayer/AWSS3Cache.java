package com.shortsands.audioplayer;

/**
 * Created by garygriswold on 8/30/17.
 */
import android.content.Context;
import android.util.Log;
import com.shortsands.aws.AwsS3;
import com.shortsands.aws.DownloadFileListener;
import com.shortsands.io.FileManager;
import java.io.File;
import java.util.Date;

class AWSS3Cache extends DownloadFileListener {

    private static final String TAG = "AWSS3Cache";

    private final Context context;
    private final CompletionHandler completionHandler;
    private final File cacheDir;

    AWSS3Cache(Context context, CompletionHandler handler) {
        super();
        this.context = context;
        this.completionHandler = handler;
        this.cacheDir = context.getCacheDir();
    }

    //deinit {
    //    print("***** Deinit AWSS3Cache *****")
    //}

    void read(String s3Bucket, String s3Key, int expireInterval) {
        String localKey = this.getLocalKey(s3Bucket, s3Key);
        File filePath = new File(this.cacheDir, localKey);
        String data = this.readCache(filePath, expireInterval);
        if (data != null) {
            this.completionHandler.completed(data, this);
        } else {
            AwsS3.shared().downloadFile(s3Bucket, s3Key, filePath, this);
            //this.downloadFile(s3Bucket, s3Key, filePath, this);
            Log.d(TAG, "**** AWSS3Cache performed downloadFile");
        }
    }

    private String readCache(File path, int expireInterval) {
        Log.d(TAG, "Path to read " + path.toString());
        String data = FileManager.readTextFully(path); // does not throw
        if (data != null) {
            if (this.isFileExpired(path, expireInterval)) {
                Log.d(TAG, "File has expired in AWSS3Cache.readCache");
                return null;
            } else {
                return data;
            }
        } else {
            return null;
        }
    }

    private String getLocalKey(String s3Bucket, String s3Key) {
        return(s3Bucket + "_" + s3Key);
    }

    private boolean isFileExpired(File filePath, int expireInterval) {
        long modificationDate = filePath.lastModified();
        Log.d(TAG, "modification date " + modificationDate);
        long now = new Date().getTime();
        Log.d(TAG, "now date " + now);
        long interval = Math.abs(now - modificationDate);
        Log.d(TAG, "interval " + interval);
        return (interval > expireInterval);
    }

    /**
     * The onComplete method and onError method are part of the DownloadFileListener interface.
     * One of them is called by AwsS3.downloadFile when the data has been downloaded.
     * @param id
     */
    @Override
    protected void onComplete(int id) {
        Log.d(TAG, "**** Inside AWSS3Cache.onComplete");
        super.onComplete(id);
        //this.results = this.file; // This is done by super
        String data = FileManager.readTextFully(this.results);
        //String data = this.results;
        this.completionHandler.completed(data, this);
    }

    @Override
    public void onError(int id, Exception e) {
        Log.d(TAG, "**** Inside AWSS3Cache.onError");
        super.onError(id, e);
        //Log.e(TAG, "Error: " + e.toString() + " on " + this.file.getAbsolutePath()); // This is done by super
        this.completionHandler.failed(e, this);
    }
}
