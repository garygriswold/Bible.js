package com.shortsands.videoplayer;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.support.test.InstrumentationRegistry;
import android.support.test.runner.AndroidJUnit4;

import org.junit.Test;
import org.junit.runner.RunWith;

import static org.junit.Assert.*;

/**
 * Instrumentation test, which will execute on an Android device.
 *
 * @see <a href="http://d.android.com/tools/testing">Testing documentation</a>
 */
@RunWith(AndroidJUnit4.class)
public class ExampleInstrumentedTest {
    @Test
    public void useAppContext() throws Exception {
        // Context of the app under test.
        Context appContext = InstrumentationRegistry.getTargetContext();

        assertEquals("com.shortsands.videoplayer.test", appContext.getPackageName());
    }
    //
    // These Tests Do Not Work.  something wrong in the setup of the test?
    //
    //@Test
    public void playValidVideo() {
        Context appContext = InstrumentationRegistry.getTargetContext();
        final Intent videoIntent = new Intent(appContext, VideoActivity.class);
        String videoUrl = "https://arc.gt/6u3oe?apiSessionId=59323fee237b64.08763601";
        Bundle extras = new Bundle();
        extras.putString("mediaSource", "JFP");
        extras.putString("videoId", "Jesus");
        extras.putString("languageId", "520");
        extras.putString("silLang", "eng");
        extras.putString("videoUrl", videoUrl);
        videoIntent.putExtras(extras);
        appContext.startActivity(videoIntent);
    }
    //@Test
    public void playNonHLSVideo() {
        Context appContext = InstrumentationRegistry.getTargetContext();
        final Intent videoIntent = new Intent(appContext, VideoActivity.class);
        String videoUrl = "https://arc.gt/1e62h?apiSessionId=587858aea460f2.62190595";
        Bundle extras = new Bundle();
        extras.putString("mediaSource", "JFP");
        extras.putString("videoId", "Jesus");
        extras.putString("languageId", "520");
        extras.putString("silLang", "eng");
        extras.putString("videoUrl", videoUrl);
        videoIntent.putExtras(extras);
        appContext.startActivity(videoIntent);
    }
}
