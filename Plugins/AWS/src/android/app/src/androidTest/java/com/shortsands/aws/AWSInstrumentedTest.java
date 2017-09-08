package com.shortsands.aws;

import android.content.Context;
import android.support.annotation.NonNull;
import android.support.test.InstrumentationRegistry;
import android.support.test.runner.AndroidJUnit4;
import android.util.Log;

import org.json.JSONObject;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;

import java.io.File;
import java.net.URL;
import java.util.concurrent.CountDownLatch;

import static org.junit.Assert.*;

/**
 * Instrumentation test, which will execute on an Android device.
 *
 * @see <a href="http://d.android.com/tools/testing">Testing documentation</a>
 */
@RunWith(AndroidJUnit4.class)
public class AWSInstrumentedTest {

    static String TAG = "AwsS3";

    @Before
    public void setUp() throws Exception {
        AwsS3.initialize("us-west-2", InstrumentationRegistry.getTargetContext());
        //AwsS3.initialize("us-east-1", InstrumentationRegistry.getTargetContext());
    }

    //@Test
    public void getPresignedGetURL() throws Exception {
        AwsS3 s3 = AwsS3.shared();
        URL result1 = s3.preSignedUrlGET("shortsands", "WEB.db.zip", 3600);
        assertEquals("Whoops getPresignedGetURL", "s3-us-west-2.amazonaws.com", result1.getHost());
    }
    //@Test
    public void getPresignedPutURL() throws Exception {
        AwsS3 s3 = AwsS3.shared();
        URL result2 = s3.preSignedUrlPUT("shortsands", "abcd", 3600, "text/plain");
        assertEquals("Whoops getPresignedPutURL", "s3-us-west-2.amazonaws.com", result2.getHost());
    }
    class DownloadTextTest extends DownloadTextListener {
        DownloadTextListener listener = this;
        CountDownLatch latch = new CountDownLatch(1);
        public void doTest() {
            AwsS3 s3 = AwsS3.shared();
            s3.downloadText("shortsands", "hello1", listener);
            try { latch.await(); } catch (InterruptedException ex) { Log.e(TAG, "Interrupted Exception"); }
            Log.d(TAG, "Expect: Hello World");
        }
        public void onError(int id, Exception e) {
            super.onError(id, e);
            Log.e(TAG, "Error: " + e.toString() + " on " + this.file.getAbsolutePath());
            Log.d(TAG, "RESULTS |" + this.results + "|");
            assertEquals("DownloadTextTest", "Hello World", this.results);
            latch.countDown();
        }
        protected void onComplete(int id) {
            super.onComplete(id);
            Log.d(TAG, "onComplete ID " + id);
            assertEquals("DownloadTextTest", "Hello World", this.results);
            latch.countDown();
        }
    }
    @Test
    public void downloadText() throws Exception {
        new DownloadTextTest().doTest();
    }
    class DownloadDataTest extends DownloadDataListener {
        DownloadDataListener listener = this;
        CountDownLatch latch = new CountDownLatch(1);
        public void doTest() {
            AwsS3 s3 = AwsS3.shared();
            s3.downloadData("shortsands", "EmmaFirstLostTooth.mp3", listener);
            try { latch.await(); } catch (InterruptedException ex) { Log.e(TAG, "Interrupted Exception"); }
        }
        public void onError(int id, Exception e) {
            super.onError(id, e);
            Log.e(TAG, "Error: " + e.toString() + " on " + this.file.getAbsolutePath());
            Log.d(TAG, "RESULTS |" + this.results + "|");
            assertEquals("DownloadDataTest", 533651, this.results.length);
            latch.countDown();
        }
        protected void onComplete(int id) {
            super.onComplete(id);
            Log.d(TAG, "onComplete ID " + id);
            assertEquals("DownloadDataTest", 533651, this.results.length);
            latch.countDown();
        }
    }
    //@Test
    public void downloadData() throws Exception {
        new DownloadDataTest().doTest();
    }
    class DownloadFileTest extends DownloadFileListener {
        DownloadFileListener listener = this;
        CountDownLatch latch = new CountDownLatch(1);
        public void doTest() {
            File root = InstrumentationRegistry.getTargetContext().getFilesDir();
            File file1 = new File(root, "EmmaLooseTooth.mp3");
            AwsS3 s3 = AwsS3.shared();
            s3.downloadFile("shortsands", "EmmaFirstLostTooth.mp3", file1, listener);
            try { latch.await(); } catch (InterruptedException ex) { Log.e(TAG, "Interrupted Exception"); }
        }
        public void onError(int id, Exception e) {
            super.onError(id, e);
            Log.e(TAG, "Error: " + e.toString() + " on " + this.file.getAbsolutePath());
            Log.d(TAG, "RESULTS |" + this.results + "|");
            assertEquals("DownloadFileTest", 533651, this.results.length());
            latch.countDown();
        }
        protected void onComplete(int id) {
            super.onComplete(id);
            Log.d(TAG, "onComplete ID " + id);
            assertEquals("DownloadFileTest", 533651, this.results.length());
            latch.countDown();
        }
    }
    //@Test
    public void downloadFile() throws Exception {
        new DownloadFileTest().doTest();
    }
    class DownloadZipFileTest extends DownloadZipFileListener {
        DownloadZipFileListener listener = this;
        CountDownLatch latch = new CountDownLatch(1);
        public void doTest() {
            File root = InstrumentationRegistry.getTargetContext().getFilesDir();
            File file1 = new File(root, "ERV-UKR.db.zip");
            AwsS3 s3 = AwsS3.shared();
            s3.downloadZipFile("shortsands", "ERV-UKR.db", file1, listener);
            try { latch.await(); } catch (InterruptedException ex) { Log.e(TAG, "Interrupted Exception"); }
        }
        public void onError(int id, Exception e) {
            super.onError(id, e);
            Log.e(TAG, "Error: " + e.toString() + " on " + this.file.getAbsolutePath());
            Log.d(TAG, "RESULTS |" + this.results + "|");
            assertEquals("DownloadZipFileTest", 533651, this.results.length());
            latch.countDown();
        }
        protected void onComplete(int id) {
            super.onComplete(id);
            Log.d(TAG, "onComplete ID " + id);
            assertEquals("DownloadZipFileTest", 533651, this.results.length());
            latch.countDown();
        }
    }
    //@Test  This one is not working GNG 9/7/2017
    public void downloadZipFile() throws Exception {
        new DownloadZipFileTest().doTest();
    }
    //@Test
    public void downloadInvalidZipFile() throws Exception {
        // invalid zip file, but zip did not fail, it returned itself.
        Context context = InstrumentationRegistry.getTargetContext();
        File file4 = new File(context.getExternalCacheDir(), "Whatever.mp3");
        DownloadZipFileListener listener4 = new DownloadZipFileListener();
        AwsS3.shared().downloadZipFile("shortsands", "hello1", file4, listener4);
        Log.d(TAG, "Expect /storage/emulated/0/Android/data/com.shortsands.aws_s3_android/cache/Whatever.mp3.");
        assertEquals("Whoops", "abc", "def");
    }
    //@Test
    public void uploadAnalytics() throws Exception {
        JSONObject json = new JSONObject();
        json.put("sample", "value1");
        UploadDataListener listener1 = new UploadDataListener();
        AwsS3.shared().uploadAnalytics("sessionId", "2017-01-01T12:12:12", "TestV1", json.toString(), listener1);
        Thread.sleep(10000);
        assertEquals("What", "Hi", listener1.file.getName());
        Log.d(TAG, "Check Log Error: com.amazonaws.services.s3");
    }
}

