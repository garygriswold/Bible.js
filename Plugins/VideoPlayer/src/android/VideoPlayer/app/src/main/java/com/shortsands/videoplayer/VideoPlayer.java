/**
* This class is the cordova native interface code that calls the VideoPlayer.
* It deliberately contains as little logic as possible so that the VideoPlayer
* can be unit tested as an Android Studio project.
*/
package com.shortsands.videoplayer;

import android.app.Activity;
import android.content.ContentResolver;
import android.content.Intent;
import android.graphics.Color;
import android.os.Build;
import android.os.Bundle;
import android.util.Log;
import java.lang.reflect.Method;
import java.util.Iterator;
import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CordovaWebView;
import org.apache.cordova.PluginResult;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

public class VideoPlayer extends CordovaPlugin {

	private static final int ACTIVITY_CODE_PLAY_MEDIA = 7;

	private CallbackContext callbackContext;

	private static final String TAG = "VideoPlayer";
	
	@Override
	public void initialize(CordovaInterface cordova, CordovaWebView webView) {
    	super.initialize(cordova, webView);
		// your init code here
	}

	@Override
	public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
		Log.d(TAG, "*** INSIDE VIDEO PLUGIN PRESENT");
		this.callbackContext = callbackContext;
		JSONObject options = null;

		if (action.equals("present")) {
			return present(VideoActivity.class, args.getString(0));
		} else {
			callbackContext.error("VideoPlayer." + action + " is not a supported method.");
			return false;			
		}
	}

	private boolean present(final Class activityClass, final String url) {
		final CordovaInterface cordovaObj = cordova;
		final CordovaPlugin plugin = this;
		
		Method[] array = activityClass.getMethods();

		cordova.getActivity().runOnUiThread(new Runnable() {
			public void run() {
				final Intent videoIntent = new Intent(cordovaObj.getActivity().getApplicationContext(), activityClass);
				Bundle extras = new Bundle();
				extras.putString("videoUrl", url);

				cordovaObj.startActivityForResult(plugin, videoIntent, ACTIVITY_CODE_PLAY_MEDIA);
			}
		});
		return true;
	}

	public void onActivityResult(int requestCode, int resultCode, Intent intent) {
		Log.v(TAG, "onActivityResult: " + requestCode + " " + resultCode);
		super.onActivityResult(requestCode, resultCode, intent);
		if (ACTIVITY_CODE_PLAY_MEDIA == requestCode) {
			if (Activity.RESULT_OK == resultCode) {
				this.callbackContext.success();
			} else if (Activity.RESULT_CANCELED == resultCode) {
				String errMsg = "Error";
				if (intent != null && intent.hasExtra("message")) {
					errMsg = intent.getStringExtra("message");
				}
				this.callbackContext.error(errMsg);
			}
		}
	}
}

