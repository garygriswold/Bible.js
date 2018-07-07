package com.shortsands.audioplayer;

/**
 * Created by garygriswold on 3/13/18.
 *
 * There is no android control center similar to iOS.
 * So, this class is just a placeholder till one appears.
 */
import android.webkit.ValueCallback;
import android.webkit.WebView;
import android.util.Log;

public class AudioControlCenter {

    private static String TAG = "AudioControlCenter";

    static AudioControlCenter shared = new AudioControlCenter();

    private AudioControlCenter() {

    }
    void setupControlCenter(AudioBible player) {

    }
    void nowPlaying(AudioBible player) {
        AudioReference reference = player.getCurrReference();
        if (reference != null) {
            this.updateTextPosition(reference.getNodeId(0));
        }
    }
    void nowPlayingUpdate(AudioReference reference, int verse, long position) {
    }
    void updateTextPosition(String nodeId) {
        Log.d(TAG, "NodeId: " + nodeId);
        final String msg = "document.dispatchEvent(new CustomEvent(BIBLE.SCROLL_TEXT," +
                " { detail: { id: '" + nodeId + "' }}));";
        Log.d(TAG, "DISPATCH EVENT LISTENING TO " + nodeId);
        ValueCallback<String> completion = new ValueCallback<String>() {
            @Override
            public void onReceiveValue(String value) {
                Log.d(TAG, "BIBLE Scroll Event Dispatched " + msg);
            }
        };
        AudioBibleView.evaluateJavascript(msg, completion);
    }
}
