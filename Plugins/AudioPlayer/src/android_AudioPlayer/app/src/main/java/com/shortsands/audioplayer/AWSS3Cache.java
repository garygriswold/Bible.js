package com.shortsands.audioplayer;

/**
 * Created by garygriswold on 8/30/17.
 */
import android.content.Context;
import android.util.Log;
import com.amazonaws.mobileconnectors.s3.transferutility.*;
import com.amazonaws.services.s3.AmazonS3;
import com.shortsands.aws.AwsS3;
import com.shortsands.aws.DownloadFileListener;
import com.shortsands.io.FileManager;
import java.io.File;
import java.util.Date;


public class AWSS3Cache extends DownloadFileListener {

    //private static String AWS_KEY_ID = "AKIAI5BBVXQGO2SHKIRQ";
    //private static String AWS_SECRET = "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";
    //public static BasicAWSCredentials AWS_BIBLE_APP = new BasicAWSCredentials(AWS_KEY_ID, AWS_SECRET);

    private static String TAG = "AWSS3Cache";

    private Context context;
    private CompletionHandler completionHandler;
    private File cacheDir;

    public AWSS3Cache(Context context, CompletionHandler handler) {
        super();
        this.context = context;
        this.completionHandler = handler;
        this.cacheDir = context.getCacheDir();
    }

    //deinit {
    //    print("***** Deinit AWSS3Cache *****")
    //}

    public void read(String s3Bucket, String s3Key, int expireInterval) {
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

    /**
     * Download File.  This really belongs in AWSS3.

    private void downloadFile(String s3Bucket, String s3Key, File file, DownloadFileListener listener) {
        listener.setFile(file);
        AmazonS3 amazonS3 = new AmazonS3Client(AWSS3Cache.AWS_BIBLE_APP);
        Region region = RegionUtils.getRegion("us-west-2");
        amazonS3.setRegion(region);
        S3ClientOptions options = new S3ClientOptions();
        options.withPathStyleAccess(true);
        amazonS3.setS3ClientOptions(options);
        TransferUtility transferUtility = new TransferUtility(amazonS3, this.context);
        TransferObserver observer = transferUtility.download(s3Bucket, s3Key, file);
        observer.setTransferListener(listener);
    }
*/
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
