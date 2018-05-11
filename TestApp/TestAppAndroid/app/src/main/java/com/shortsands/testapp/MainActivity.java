package com.shortsands.testapp;

import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.webkit.ValueCallback;
import android.webkit.WebView;

/**
 * https://stackoverflow.com/questions/22895140/call-android-methods-from-javascript
 */

public class MainActivity extends AppCompatActivity {

    private WebView webview;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        this.webview = new WebView(this);
        setContentView(this.webview);
        this.webview.loadUrl("file:///android_asset/www/index.html");

        this.webview.getSettings().setJavaScriptEnabled(true);
        JSMessageHandler handler = new JSMessageHandler(this);
        this.webview.addJavascriptInterface(handler, "callAndroid");
    }

    public void jsCallback(final String message) {
        this.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                //ValueCallback<String> result = new ValueCallback<String>();
                webview.evaluateJavascript(message, null);
            }
        });
    }
}