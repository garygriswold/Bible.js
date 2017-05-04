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
	
	static VideoPersistence retrieve(Activity activity, String videoId, String videoUrl) {
		currentState.videoId = videoId;
		currentState.videoUrl = videoUrl;
		SharedPreferences savedState = activity.getSharedPreferences(videoId, Context.MODE_PRIVATE);
		if (savedState != null && savedState.contains(VIDEO_URL)) {
			currentState.currentPosition = savedState.getLong(CURRENT_POSITION, 0L);
			currentState.timestamp = savedState.getLong(TIMESTAMP, System.currentTimeMillis());
		} else {
			currentState.currentPosition = 0L;
			currentState.timestamp = System.currentTimeMillis();
		}
		return(currentState);
	}
	
	static void clear(Activity activity) {
		SharedPreferences savedState = activity.getSharedPreferences(currentState.videoId, Context.MODE_PRIVATE);
		SharedPreferences.Editor editor = savedState.edit();
		editor.clear();
		editor.apply();
		currentState = new VideoPersistence(currentState.videoId);
	}
	
	static void update(Activity activity, long time) {
		if (currentState.videoUrl != null) {
			currentState.currentPosition = time;
			currentState.timestamp = System.currentTimeMillis();
	        SharedPreferences savedState = activity.getSharedPreferences(currentState.videoId, Context.MODE_PRIVATE);
			SharedPreferences.Editor editor = savedState.edit();
			editor.putString(VIDEO_URL, currentState.videoUrl);
			editor.putLong(CURRENT_POSITION, currentState.currentPosition);
			editor.putLong(TIMESTAMP, currentState.timestamp);
			editor.commit();
		}		
	}
	

	public String videoId;
	public String videoUrl;
	public long currentPosition;
	public long timestamp;
	
	VideoPersistence(String videoId, String videoUrl, long currentPosition) {
		this.videoId = videoId;
		this.videoUrl = videoUrl;
		this.currentPosition = currentPosition;
		this.timestamp = System.currentTimeMillis();
	}

	VideoPersistence(String videoId) {
		this.videoId = videoId;
		this.videoUrl = null;
		this.currentPosition = 0L;
		this.timestamp = System.currentTimeMillis();
	}
	public String toString() {
		return("videoId:" + this.videoId + ", videoUrl:" + this.videoUrl + ", position:" + this.currentPosition + ", timestamp:" + this.timestamp);	
	};
}