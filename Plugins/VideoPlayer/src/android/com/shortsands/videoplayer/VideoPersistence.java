/**
* This class is used to persist the state of the VideoActivity accross runs of the App.
* It provides a bookmark of the current location in the videos played.
* It keeps one current bookmark for each video.
*/
package com.shortsands.videoplayer;

import android.app.Activity;
import android.content.Context;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.util.Log;
import java.util.Date;

class VideoPersistence {
	
	private static final String TAG = "VideoPersistence";
	private static final String VIDEO_ID = "videoId";
	private static final String VIDEO_URL = "videoUrl";
	private static final String CURRENT_POSITION = "currentPosition";
	private static final String TIMESTAMP = "timestamp";

	static VideoPersistence currentState = new VideoPersistence("jesusFilm");
	static Activity activity; // this was added to get this to compile, class must be rewritten.
	
	static void clearState() {
		SharedPreferences savedState = activity.getSharedPreferences(currentState.videoId, Context.MODE_PRIVATE);
		SharedPreferences.Editor editor = savedState.edit();
		editor.clear();
		editor.apply();
	}
	
	static void saveState() {
        if (currentState.videoId != null && currentState.videoUrl != null && currentState.currentPosition > 0) {
	        SharedPreferences savedState = activity.getSharedPreferences(currentState.videoId, Context.MODE_PRIVATE);
			SharedPreferences.Editor editor = savedState.edit();
			editor.putString(VIDEO_URL, currentState.videoUrl);
			editor.putInt(CURRENT_POSITION, currentState.currentPosition);
			editor.putLong(TIMESTAMP, new Date().getTime());
			editor.commit();
		}		
	}
	
	static void recoverState() {
		Bundle bundle = activity.getIntent().getExtras();
		currentState.videoId = bundle.getString(VIDEO_ID);
		currentState.videoUrl = bundle.getString(VIDEO_URL); // always take requested URL in case language changed.
		SharedPreferences savedState = activity.getSharedPreferences(currentState.videoId, Context.MODE_PRIVATE);
		if (savedState != null && savedState.contains(VIDEO_URL)) {
			currentState.currentPosition = savedState.getInt(CURRENT_POSITION, 0);
			currentState.timestamp = new Date(savedState.getLong(TIMESTAMP, new Date().getTime()));
		} else {
			currentState.currentPosition = 0;
			currentState.timestamp = new Date();
		}
	}
	
	public String videoId;
	public String videoUrl;
	public int currentPosition; // maybe long
	public Date timestamp; // maybe currentTimeMillis
	
	VideoPersistence(String videoId, String videoUrl, int currentPosition) {
		this.videoId = videoId;
		this.videoUrl = videoUrl;
		this.currentPosition = currentPosition;
		this.timestamp = new Date();
	}

	VideoPersistence(String videoId) {
		this.videoId = videoId;
		this.videoUrl = null;
		this.currentPosition = 0;
		this.timestamp = new Date();
	}
}