package com.shortsands.audioplayer;

/**
 * This class is used to persist the state of the AudioActivity across runs of the App.
 * It provides a bookmark of the current location in the audios played.
 * It keeps one current bookmark for each video.
 */
import android.app.Activity;
import android.content.Context;
import android.content.SharedPreferences;
import android.util.Log;

class AudioPlayState {

    private static final String TAG = "MediaPlayState";
    private static final String MEDIA_ID = "mediaId";
    private static final String MEDIA_URL = "mediaUrl";
    private static final String POSITION = "position";
    private static final String TIMESTAMP = "timestamp";

    static AudioPlayState currentState = new AudioPlayState("jesusFilm");

    static AudioPlayState retrieve(Activity activity, String mediaId) {
        currentState.mediaId = mediaId;
        Log.d(TAG, "***** SEEKING " + mediaId);
        SharedPreferences savedState = activity.getSharedPreferences(mediaId, Context.MODE_PRIVATE);
        if (savedState != null && savedState.contains(MEDIA_ID)) {
            currentState.mediaUrl = savedState.getString(MEDIA_URL, null);
            currentState.position = savedState.getLong(POSITION, 0L);
            currentState.timestamp = savedState.getLong(TIMESTAMP, System.currentTimeMillis());
        } else {
            currentState.mediaUrl = null;
            currentState.position = 0L;
            currentState.timestamp = System.currentTimeMillis();
        }
        return(currentState);
    }

    static void clear(Activity activity) {
        SharedPreferences savedState = activity.getSharedPreferences(currentState.mediaId, Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = savedState.edit();
        editor.clear();
        editor.apply();
        currentState = new AudioPlayState(currentState.mediaId);
    }

    static void update(Activity activity, String mediaUrl, long time) {
        currentState.mediaUrl = mediaUrl;
        currentState.position = time;
        currentState.timestamp = System.currentTimeMillis();
        SharedPreferences savedState = activity.getSharedPreferences(currentState.mediaId, Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = savedState.edit();
        editor.putString(MEDIA_ID, currentState.mediaId);
        editor.putString(MEDIA_URL, currentState.mediaUrl);
        editor.putLong(POSITION, currentState.position);
        editor.putLong(TIMESTAMP, currentState.timestamp);
        editor.commit();
    }


    String mediaId;
    String mediaUrl;
    long position;
    long timestamp;

    AudioPlayState(String mediaId, String mediaUrl, long position) {
        this.mediaId = mediaId;
        this.mediaUrl = mediaUrl;
        this.position = position;
        this.timestamp = System.currentTimeMillis();
    }

    AudioPlayState(String mediaId) {
        this.mediaId = mediaId;
        this.mediaUrl = null;
        this.position = 0L;
        this.timestamp = System.currentTimeMillis();
    }
    public String toString() {
        return("mediaId:" + this.mediaId + ", mediaUrl:" + this.mediaUrl + ", position:" + this.position + ", timestamp:" + this.timestamp);
    };
}