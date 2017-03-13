/**
* This class is used to persist the state of the VideoActivity accross runs of the App.
* It provides a bookmark of the current location in the videos played.
* It keeps one current bookmark for each video.
*/
package com.shortsands.videoplayer;

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
	private VideoActivity activity;
	
	VideoPersistence(VideoActivity videoActivity) {
		this.activity = videoActivity;
	}
	
	void clearState() {
		SharedPreferences savedState = activity.getSharedPreferences(activity.getVideoId(), Context.MODE_PRIVATE);
		SharedPreferences.Editor editor = savedState.edit();
		editor.clear();
		editor.apply();
	}
	
	void saveState() {
        if (activity.getVideoId() != null && activity.getVideoUrl() != null && activity.getCurrentPosition() > 0) {
	        SharedPreferences savedState = activity.getSharedPreferences(activity.getVideoId(), Context.MODE_PRIVATE);
			SharedPreferences.Editor editor = savedState.edit();
			editor.putString(VIDEO_URL, activity.getVideoUrl());
			editor.putInt(CURRENT_POSITION, activity.getCurrentPosition());
			editor.putLong(TIMESTAMP, new Date().getTime());
			editor.apply();
		}		
	}
	
	void recoverState() {
		Bundle bundle = activity.getIntent().getExtras();
		activity.setVideoId(bundle.getString(VIDEO_ID));
		activity.setVideoUrl(bundle.getString(VIDEO_URL)); // always take requested URL in case language changed.
		SharedPreferences savedState = activity.getSharedPreferences(activity.getVideoId(), Context.MODE_PRIVATE);
		if (savedState != null && savedState.contains(VIDEO_URL)) {
			activity.setCurrentPosition(savedState.getInt(CURRENT_POSITION, 0));
			activity.setTimestamp(new Date(savedState.getLong(TIMESTAMP, new Date().getTime())));
		} else {
			activity.setCurrentPosition(0);
			activity.setTimestamp(new Date());
		}
	}
}