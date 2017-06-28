package com.shortsands.aws;

import android.support.test.InstrumentationRegistry;
import android.support.test.runner.AndroidJUnit4;
import android.util.Log;

import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;

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
        AwsS3.initialize("us-west-2", InstrumentationRegistry.getTargetContext());
    }

    //@Test
    //public void useAppContext() throws Exception {
    //    // Context of the app under test.
    //    Context appContext = InstrumentationRegistry.getTargetContext();
    //    assertEquals("com.shortsands.aws", appContext.getPackageName());
    //}
    @Test
    public void getPresignedGetURL() throws Exception {
        AwsS3 s3 = AwsS3.shared();
        URL result1 = s3.preSignedUrlGET("shortsands", "WEB.db.zip", 3600);
        assertEquals("Whoops getPresignedGetURL", "s3-us-west-2.amazonaws.com", result1.getHost());
    }
    @Test
    public void getPresignedPutURL() throws Exception {
        AwsS3 s3 = AwsS3.shared();
        URL result2 = s3.preSignedUrlPUT("shortsands", "abcd", 3600, "text/plain");
        assertEquals("Whoops getPresignedPutURL", "s3-us-west-2.amazonaws.com", result2.getHost());
    }
}

