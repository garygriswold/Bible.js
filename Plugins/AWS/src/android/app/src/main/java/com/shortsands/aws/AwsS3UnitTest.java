package com.shortsands.aws;

import android.content.Context;
import android.util.Log;
import com.shortsands.io.FileManager;
import java.io.File;
import java.net.URL;
/**
 * Created by garygriswold on 5/23/17.
 */

public class AwsS3UnitTest {

    private static String TAG = "AwsS3UnitTest";

    private Context context;

    public AwsS3UnitTest(String regionName, Context context) {
        AwsS3.initialize(regionName, context);
        this.context = context;
    }

    public void testPresignedURL() {
        AwsS3 s3 = AwsS3.shared();
        URL result1 = s3.preSignedUrlGET("shortsands", "WEB.db.zip", 3600);

        URL result2 = s3.preSignedUrlPUT("shortsands", "abcd", 3600, "text/plain");
    }

    public void testDownloadText() {
        AwsS3 s3 = AwsS3.shared();

        // Download text
        DownloadTextListener listener1 = new DownloadTextListener();
        s3.downloadText("shortsands", "hello1", listener1);
        Log.d(TAG, "Expect: Hello World");

        // Attempt to read non-existing key
        DownloadTextListener listener2 = new DownloadTextListener();
        s3.downloadText("shortsands", "notthere", listener2);
        Log.d(TAG, "Expect Error: The specified key does not exist.");

        // Attempt to read a non-existing bucket
        DownloadTextListener listener3 = new DownloadTextListener();
        s3.downloadText("notthere", "notthere", listener3);
        Log.d(TAG, "Expect Error: The specified key does not exist.");
    }

    public void testDownloadData() {
        AwsS3 s3 = AwsS3.shared();

        DownloadDataListener listener1 = new DownloadDataListener();
        s3.downloadData("shortsands", "EmmaFirstLostTooth.mp3", listener1);
        Log.d(TAG, "Expect: [.....");

        DownloadDataListener listener2 = new DownloadDataListener();
        s3.downloadData("shortsands", "notthere", listener2);
        Log.d(TAG, "Expect Error: The specified key does not exist.");
    }

    public void testDownloadFile() {
        AwsS3 s3 = AwsS3.shared();

        File root = this.context.getFilesDir();
        File file1 = new File(root, "EmmaLooseTooth.mp3");
        DownloadFileListener listener1 = new DownloadFileListener();
        s3.downloadFile("shortsands", "EmmaFirstLostTooth.mp3", file1, listener1);
        Log.d(TAG, "Expect: Success: /data/user/0/com.shortsands.aws_s3_android/files/EmmaLooseTooth.mp3");

        File file2 = new File(this.context.getExternalCacheDir(), "EmmaLooseTooth.mp3");
        DownloadFileListener listener2 = new DownloadFileListener();
        s3.downloadFile("shortsands", "EmmaFirstLostTooth.mp3", file2, listener2);
        Log.d(TAG, "Expect Success: Success: /storage/emulated/0/Android/data/com.shortsands.aws_s3_android/cache/EmmaLooseTooth.mp3");

        File file3 = new File(this.context.getExternalCacheDir(), "Whatever.mp3");
        DownloadFileListener listener3 = new DownloadFileListener();
        s3.downloadFile("shortsands", "notthere", file3, listener3);
        Log.d(TAG, "Expect Error: The specified key does not exist.");
    }

    public void testDownloadZipFile() {
        AwsS3 s3 = AwsS3.shared();

        File root = this.context.getFilesDir();
        File file1 = new File(root, "WEB.db");
        DownloadZipFileListener listener1 = new DownloadZipFileListener();
        s3.downloadZipFile("shortsands", "WEB.db.zip", file1, listener1);
        Log.d(TAG, "Expect: Success: /data/user/0/com.shortsands.aws_s3_android/files/WEB.db");

        File file2 = new File(this.context.getExternalCacheDir(), "WEB.db");
        DownloadZipFileListener listener2 = new DownloadZipFileListener();
        s3.downloadZipFile("shortsands", "WEB.db.zip", file2, listener2);
        Log.d(TAG, "Expect Success: Success: /storage/emulated/0/Android/data/com.shortsands.aws_s3_android/cache/WEB.db");

        File file3 = new File(this.context.getExternalCacheDir(), "Whatever.mp3");
        DownloadZipFileListener listener3 = new DownloadZipFileListener();
        s3.downloadZipFile("shortsands", "notthere", file3, listener3);
        Log.d(TAG, "Expect Error: The specified key does not exist.");
        // invalid zip file, but zip did not fail, it returned itself.
        File file4 = new File(this.context.getExternalCacheDir(), "Whatever.mp3");
        DownloadZipFileListener listener4 = new DownloadZipFileListener();
        s3.downloadZipFile("shortsands", "hello1", file4, listener4);
        Log.d(TAG, "Expect /storage/emulated/0/Android/data/com.shortsands.aws_s3_android/cache/Whatever.mp3.");
    }

    public void testUploadAnalytics() {
        AwsS3 s3 = AwsS3.shared();

        UploadDataListener listener1 = new UploadDataListener();
        s3.uploadAnalytics("1234512345", "2017-05-23T23:22:00", "HelloV1", "{message: more}", listener1);
        Log.d(TAG, "Expect: /data/user/0/com.shortsands.aws_s3_android/cache/uploadText2127452064");
    }

    public void testUploadText() {
        AwsS3 s3 = AwsS3.shared();

        UploadDataListener listener1 = new UploadDataListener();
        s3.uploadText("shortsands", "Hello_123", "{Hello World Message}", listener1);
        Log.d(TAG, "Expect: /data/user/0/com.shortsands.aws_s3_android/cache/uploadText1455592352");

        UploadDataListener listener2 = new UploadDataListener();
        s3.uploadText("nowhere", "Hello_123", "{Bad Hello World Message}", listener2);
        Log.d(TAG, "Expect: Access Denied (Service: Amazon S3; Status Code: 403; Error Code: AccessDenied;");
    }

    public void testUploadData() {
        AwsS3 s3 = AwsS3.shared();

        File testData = new File(this.context.getFilesDir(), "EmmaLooseTooth.mp3");
        byte[] bytes = FileManager.readBinaryFully(testData);


        UploadDataListener listener1 = new UploadDataListener();
        s3.uploadData("shortsands", "upload_emma_test.mp3", bytes, listener1);
        Log.d(TAG, "Expect: /data/user/0/com.shortsands.aws_s3_android/cache/uploadData1019506572");

        // Test non-existing bucket
        UploadDataListener listener2 = new UploadDataListener();
        s3.uploadData("nothere", "XXX_upload_emma_test.mp3", bytes, listener2);
        Log.d(TAG, "Expect: The specified bucket does not exist ");

        // test null bytes - result is a empty file uploaded
        UploadDataListener listener3 = new UploadDataListener();
        s3.uploadData("shortsands", "YYY_upload_emma_test.mp3", null, listener3);
        Log.d(TAG, "Expect: /data/user/0/com.shortsands.aws_s3_android/cache/uploadData2141525955");
    }

    public void testUploadFile() {
        AwsS3 s3 = AwsS3.shared();

        // Valid file upload.  It was downloaded by testDownloadFile
        File file1 = new File(this.context.getFilesDir(), "EmmaLooseTooth.mp3");
        UploadFileListener listener1 = new UploadFileListener();
        s3.uploadFile("shortsands", "upload_test_1", file1, listener1);
        Log.d(TAG, "Expect:  Success: /data/user/0/com.shortsands.aws_s3_android/files/EmmaLooseTooth.mp3");

        // Attempt to upload a non-existent file
        File file2 = new File(this.context.getFilesDir(), "Not_There.mp3");
        UploadFileListener listener2 = new UploadFileListener();
        s3.uploadFile("shortsands", "XXX_upload_test_1", file2, listener2);
        Log.d(TAG, "Expect:  Success: /data/user/0/com.shortsands.aws_s3_android/files/EmmaLooseTooth.mp3");

        // Attempt to upload a non-existent bucket
        File file3 = new File(this.context.getFilesDir(), "EmmaLooseTooth.mp3");
        UploadFileListener listener3 = new UploadFileListener();
        s3.uploadFile("notthere", "XXX_upload_test_1", file3, listener3);
        Log.d(TAG, "Expect:  Access Denied (Service: Amazon S3; ");
    }
}
