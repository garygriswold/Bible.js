package com.shortsands.yourbible;

import android.app.Activity;
import android.content.Intent;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.Log;
import android.webkit.ValueCallback;
import android.webkit.WebView;
import android.webkit.WebSettings;
import com.shortsands.audioplayer.AudioBibleController;

/**
 * https://stackoverflow.com/questions/22895140/call-android-methods-from-javascript
 */

public class MainActivity extends AppCompatActivity {

    public static final int ACTIVITY_CODE_PLAY_VIDEO = 7;
    private static String TAG = "MainActivity";

    private WebView webView;
    private JSMessageHandler handler;
    // Transient
    private String videoCallbackId;
    private String videoMethod;

    public WebView getWebview() {
        return webView;
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        this.webView = new WebView(this);
        WebSettings settings = this.webView.getSettings();
        settings.setAllowFileAccessFromFileURLs(true); // Enables Dynamic CSS manipulation
        settings.setBlockNetworkLoads(true); // App Security
        settings.setCacheMode(WebSettings.LOAD_NO_CACHE); // This should help performance
        settings.setJavaScriptEnabled(true);
        this.handler = new JSMessageHandler(this);
        this.webView.addJavascriptInterface(this.handler, "callAndroid");

        setContentView(this.webView);
        this.webView.loadUrl("file:///android_asset/www/index.html");
    }

    public void startVideoActivity(String callbackId, String method, final Intent intent) {
        this.videoCallbackId = callbackId;
        this.videoMethod = method;

        this.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                startActivityForResult(intent, ACTIVITY_CODE_PLAY_VIDEO);
            }
        });
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent intent) {
        Log.d(TAG, "onActivityResult: " + requestCode + " " + resultCode + " " + System.currentTimeMillis());

        if (ACTIVITY_CODE_PLAY_VIDEO == requestCode) {
            if (Activity.RESULT_OK == resultCode) {
                this.handler.jsSuccess(this.videoCallbackId);
            } else if (Activity.RESULT_CANCELED == resultCode) {
                String errMsg = "Error";
                if (intent != null && intent.hasExtra("message")) {
                    errMsg = intent.getStringExtra("message");
                }
                this.handler.jsError(this.videoCallbackId, this.videoMethod, errMsg);
            }
        }
    }

    /**
     * Called when the system is about to start resuming a previous activity.
     *
     * @param multitasking		Flag indicating if multitasking is turned on for app
     */
    @Override
    public void onPause(boolean multitasking) {
        Log.d(TAG, "Inside MainActivity.onPause");
    }

    /**
     * Called when the activity will start interacting with the user.
     *
     * @param multitasking		Flag indicating if multitasking is turned on for app
     */
    @Override
    public void onResume(boolean multitasking) {
        Log.d(TAG, "Inside MainActivity.onResume");
    }

    /**
     * Called when the activity is becoming visible to the user.
     */
    @Override
    public void onStart() {
        Log.d(TAG, "Inside MainActivity.onStart");
    }

    /**
     * Called when the activity is no longer visible to the user.
     */
    @Override
    public void onStop() {
        Log.d(TAG, "Inside MainActivity.onStop");
    }

    /**
     * The final call you receive before your activity is destroyed.
     */
    @Override
    public void onDestroy() {
        Log.d(TAG, "Inside MainActivity.onDestroy");
        AudioBibleController audioController = AudioBibleController.shared(this);
        audioController.stop();
    }
}
