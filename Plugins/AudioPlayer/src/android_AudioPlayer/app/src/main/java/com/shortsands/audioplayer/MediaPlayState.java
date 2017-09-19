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

class MediaPlayState {

    private static final String TAG = "MediaPlayState";
    private static final String MEDIA_ID = "mediaId";
    private static final String MEDIA_URL = "mediaUrl";
    private static final String POSITION = "position";
    private static final String TIMESTAMP = "timestamp";

    static MediaPlayState currentState = new MediaPlayState("jesusFilm");

    static MediaPlayState retrieve(Activity activity, String mediaId, String mediaUrl) {
        currentState.mediaId = mediaId;
        currentState.mediaUrl = mediaUrl;
        Log.d(TAG, "***** SEEKING " + mediaId + "  " + mediaUrl);
        SharedPreferences savedState = activity.getSharedPreferences(mediaId, Context.MODE_PRIVATE);
        if (savedState != null) {
            String id = savedState.getString(MEDIA_ID, "");
            String url = savedState.getString(MEDIA_URL, "");
            Log.d(TAG, "***** SAVED STATE " + id + "   " + url);
        }
        if (savedState != null && savedState.contains(MEDIA_ID) && mediaUrl.equals(savedState.getString(MEDIA_URL, ""))) {
            currentState.position = savedState.getLong(POSITION, 0L);
            currentState.timestamp = savedState.getLong(TIMESTAMP, System.currentTimeMillis());
        } else {
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
        currentState = new MediaPlayState(currentState.mediaId);
    }

    static void update(Activity activity, String mediaUrl, int time) {
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


    public String mediaId;
    public String mediaUrl;
    public long position;
    public long timestamp;

    MediaPlayState(String mediaId, String mediaUrl, long position) {
        this.mediaId = mediaId;
        this.mediaUrl = mediaUrl;
        this.position = position;
        this.timestamp = System.currentTimeMillis();
    }

    MediaPlayState(String mediaId) {
        this.mediaId = mediaId;
        this.mediaUrl = null;
        this.position = 0L;
        this.timestamp = System.currentTimeMillis();
    }
    public String toString() {
        return("mediaId:" + this.mediaId + ", mediaUrl:" + this.mediaUrl + ", position:" + this.position + ", timestamp:" + this.timestamp);
    };
}