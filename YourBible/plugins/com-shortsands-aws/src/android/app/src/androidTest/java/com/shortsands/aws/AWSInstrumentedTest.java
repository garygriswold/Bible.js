package com.shortsands.aws;

import android.content.Context;
import android.support.test.InstrumentationRegistry;
import android.support.test.runner.AndroidJUnit4;
import android.util.Log;

import org.json.JSONObject;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;

import java.io.File;
import java.net.URL;
import java.util.concurrent.TimeUnit;

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
        //AwsS3.initialize("us-west-2", InstrumentationRegistry.getTargetContext());
        AwsS3.initialize("us-east-1", InstrumentationRegistry.getTargetContext());
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
    public void downloadTextFile() throws Exception {
        DownloadTextListener listener1 = new DownloadTextListener();
        AwsS3.shared().downloadText("shortsands", "hello1", listener1);
        Thread.sleep(10000);
        assertEquals("Expect Hello World", "Hello World", listener1.results);
    }
    @Test
    public void uploadAnalytics() throws Exception {
        JSONObject json = new JSONObject();
        json.put("sample", "value1");
        UploadDataListener listener1 = new UploadDataListener();
        AwsS3.shared().uploadAnalytics("sessionId", "2017-01-01T12:12:12", "TestV1", json.toString(), listener1);
        Thread.sleep(10000);
        Log.d(TAG, "Check Log Error: com.amazonaws.services.s3");
    }
}

