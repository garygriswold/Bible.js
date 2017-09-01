package com.shortsands.audioplayer;

import android.content.Context;
import android.app.Activity;
import android.app.Service;
import android.app.IntentService;
/**
 * Created by garygriswold on 8/30/17.
 */

public class AudioBibleController {

    public Context context;

    public AudioBibleController(Context context) {
        this.context = context;
    }

    public void present() { // one parameter view
        AudioBible audioBible = new AudioBible(this, null, null);
        audioBible.beginStreaming();
    }

    public void playHasStarted() {

    }

    public void playHasStopped() {

    }
}
