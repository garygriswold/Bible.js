/**
* This class is the cordova native interface code that calls the VideoPlayer.
* It deliberately contains as little logic as possible so that the VideoPlayer
* can be unit tested as an Android Studio project.
*/
package com.shortsands.videoplayer;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CordovaWebView;
import org.apache.cordova.PluginResult;
import org.json.JSONArray;
import org.json.JSONException;

public class VideoPlayer extends CordovaPlugin {

	private static final int ACTIVITY_CODE_PLAY_VIDEO = 7;
	private static final String TAG = "VideoPlayer";
	private CallbackContext callbackContext;
	
	@Override
	public void initialize(CordovaInterface cordova, CordovaWebView webView) {
    	super.initialize(cordova, webView);
		// your init code here
	}

	@Override
	public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
		Log.d(TAG, "*** INSIDE VIDEO PLUGIN PRESENT " + System.currentTimeMillis());
		this.callbackContext = callbackContext;

		if (action.equals("present")) {
			present(args.getString(0), args.getInt(1));
			return true;
		} else {
			callbackContext.error("VideoPlayer." + action + " is not a supported method.");
			return false;			
		}
	}

	private void present(final String url, final int seekSec) {
		//final CordovaInterface cordovaObj = cordova;
		final CordovaPlugin plugin = this;

		cordova.getActivity().runOnUiThread(new Runnable() {
			public void run() {
				final Intent videoIntent = new Intent(cordova.getActivity().getApplicationContext(), VideoActivity.class);
				Bundle extras = new Bundle();
				extras.putString("videoUrl", url);
				extras.putInt("seekSec", seekSec);
                videoIntent.putExtras(extras);
				cordova.startActivityForResult(plugin, videoIntent, ACTIVITY_CODE_PLAY_VIDEO);
			}
		});
	}
	
	 /**
     * Called when the system is about to start resuming a previous activity.
     *
     * @param multitasking		Flag indicating if multitasking is turned on for app
     */
    @Override
    public void onPause(boolean multitasking) {
	    Log.d(TAG, "onPause " + System.currentTimeMillis());
    }
	
	/**
     * Called when the activity will start interacting with the user.
     *
     * @param multitasking		Flag indicating if multitasking is turned on for app
     */
    @Override
    public void onResume(boolean multitasking) {
	    Log.d(TAG, "onResume " + System.currentTimeMillis());
    }
    
    /**
     * Called when the activity is becoming visible to the user.
     */
    @Override
    public void onStart() {
	    Log.d(TAG, "onStart " + System.currentTimeMillis());
    }

    /**
     * Called when the activity is no longer visible to the user.
     */
    @Override
    public void onStop() {
	    Log.d(TAG, "onStop " + System.currentTimeMillis());
    }

    /**
     * Called when the activity receives a new intent.
     */
    @Override
    public void onNewIntent(Intent intent) {
	    Log.d(TAG, "onNewIntent " + System.currentTimeMillis());
    }

    /**
     * The final call you receive before your activity is destroyed.
     */
    @Override
    public void onDestroy() {
	    Log.d(TAG, "onDestroy " + System.currentTimeMillis());
    }
    
    /**
     * Called when the Activity is being destroyed (e.g. if a plugin calls out to an external
     * Activity and the OS kills the CordovaActivity in the background). The plugin should save its
     * state in this method only if it is awaiting the result of an external Activity and needs
     * to preserve some information so as to handle that result; onRestoreStateForActivityResult()
     * will only be called if the plugin is the recipient of an Activity result
     *
     * @return  Bundle containing the state of the plugin or null if state does not need to be saved
     */
    @Override
    public Bundle onSaveInstanceState() {
	    Log.d(TAG, "onSaveInstanceState " + System.currentTimeMillis());
        return null;
    }
    
    /**
     * Called when a plugin is the recipient of an Activity result after the CordovaActivity has
     * been destroyed. The Bundle will be the same as the one the plugin returned in
     * onSaveInstanceState()
     *
     * @param state             Bundle containing the state of the plugin
     * @param callbackContext   Replacement Context to return the plugin result to
     */
    @Override
    public void onRestoreStateForActivityResult(Bundle state, CallbackContext callbackContext) {
	    Log.d(TAG, "onRestoreStateForActivityResult " + System.currentTimeMillis());
    }
    
    /**
     * Called when a message is sent to plugin.
     *
     * @param id            The message id
     * @param data          The message data
     * @return              Object to stop propagation or null
     */
    @Override
    public Object onMessage(String id, Object data) {
	    Log.d(TAG, "onMessage " + System.currentTimeMillis());
        return null;
    }
	
    /**
     * Called when an activity you launched exits, giving you the requestCode you started it with,
     * the resultCode it returned, and any additional data from it.
     *
     * @param requestCode   The request code originally supplied to startActivityForResult(),
     *                      allowing you to identify who this result came from.
     * @param resultCode    The integer result code returned by the child activity through its setResult().
     * @param intent        An Intent, which can return result data to the caller (various data can be
     *                      attached to Intent "extras").
     */
    @Override
	public void onActivityResult(int requestCode, int resultCode, Intent intent) {
		Log.d(TAG, "onActivityResult: " + requestCode + " " + resultCode + " " + System.currentTimeMillis());
		Log.d(TAG, "requestCode=" + requestCode);
		Log.d(TAG, "resultCode=" + resultCode);
		Bundle bundle = intent.getExtras();
		String videoUrl = bundle.getString("videoUrl");
		int seekSec = bundle.getInt("seekSec");
		Log.d(TAG, "videoUrl=" + videoUrl);
		Log.d(TAG, "seekSec=" + seekSec);
		
		if (ACTIVITY_CODE_PLAY_VIDEO == requestCode) {
			if (Activity.RESULT_OK == resultCode) {
				this.callbackContext.success();  // Try rewrting and PluginResponse
			} else if (Activity.RESULT_CANCELED == resultCode) {
				String errMsg = "Error";
				if (intent != null && intent.hasExtra("message")) {
					errMsg = intent.getStringExtra("message");
				}
				this.callbackContext.error(errMsg);
			}
		}
	}
	
	/**
     * Called when the WebView does a top-level navigation or refreshes.
     *
     * Plugins should stop any long-running processes and clean up internal state.
     *
     * Does nothing by default.
     */
    @Override
    public void onReset() {
	    Log.d(TAG, "onReset " + System.currentTimeMillis());
    }
}

