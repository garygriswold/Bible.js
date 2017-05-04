/**
* This class is used to persist the state of the AudioActivity accross runs of the App.
* It provides a bookmark of the current location in the audios played.
* It keeps one current bookmark for each audio.
*/
package com.shortsands.audioplayer;

import android.app.Activity;
import android.content.Context;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.util.Log;
import java.util.Date;

class AudioPersistence {
	
	private static final String TAG = "AudioPersistence";
	private static final String AUDIO_ID = "audioId";
	private static final String AUDIO_URL = "audioUrl";
	private static final String CURRENT_POSITION = "currentPosition";
	private static final String TIMESTAMP = "timestamp";

	static AudioPersistence currentState = new AudioPersistence("jesusFilm");
	
	static AudioPersistence retrieve(Activity activity, String audioId, String audioUrl) {
		currentState.audioId = audioId;
		currentState.audioUrl = audioUrl;
		SharedPreferences savedState = activity.getSharedPreferences(audioId, Context.MODE_PRIVATE);
		if (savedState != null && savedState.contains(AUDIO_URL)) {
			currentState.currentPosition = savedState.getLong(CURRENT_POSITION, 0L);
			currentState.timestamp = savedState.getLong(TIMESTAMP, System.currentTimeMillis());
		} else {
			currentState.currentPosition = 0L;
			currentState.timestamp = System.currentTimeMillis();
		}
		return(currentState);
	}
	
	static void clear(Activity activity) {
		SharedPreferences savedState = activity.getSharedPreferences(currentState.audioId, Context.MODE_PRIVATE);
		SharedPreferences.Editor editor = savedState.edit();
		editor.clear();
		editor.apply();
		currentState = new AudioPersistence(currentState.audioId);
	}
	
	static void update(Activity activity, long time) {
		if (currentState.audioUrl != null) {
			currentState.currentPosition = time;
			currentState.timestamp = System.currentTimeMillis();
	        SharedPreferences savedState = activity.getSharedPreferences(currentState.audioId, Context.MODE_PRIVATE);
			SharedPreferences.Editor editor = savedState.edit();
			editor.putString(AUDIO_URL, currentState.audioUrl);
			editor.putLong(CURRENT_POSITION, currentState.currentPosition);
			editor.putLong(TIMESTAMP, currentState.timestamp);
			editor.commit();
		}		
	}
	

	public String audioId;
	public String audioUrl;
	public long currentPosition;
	public long timestamp;
	
	AudioPersistence(String audioId, String audioUrl, long currentPosition) {
		this.audioId = audioId;
		this.audioUrl = audioUrl;
		this.currentPosition = currentPosition;
		this.timestamp = System.currentTimeMillis();
	}

	AudioPersistence(String audioId) {
		this.audioId = audioId;
		this.audioUrl = null;
		this.currentPosition = 0L;
		this.timestamp = System.currentTimeMillis();
	}
	public String toString() {
		return("audioId:" + this.audioId + ", audioUrl:" + this.audioUrl + ", position:" + this.currentPosition + ", timestamp:" + this.timestamp);	
	};
}