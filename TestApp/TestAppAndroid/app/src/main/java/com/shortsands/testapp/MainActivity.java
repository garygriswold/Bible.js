package com.shortsands.testapp;

import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;

import android.webkit.WebView;

/**
 * https://stackoverflow.com/questions/22895140/call-android-methods-from-javascript
 */

public class MainActivity extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        WebView webview = new WebView(this);
        setContentView(webview);
        webview.loadUrl("file:///android_asset/www/index.html");

        webview.getSettings().setJavaScriptEnabled(true);
        JSMessageHandler handler = new JSMessageHandler(this);
        webview.addJavascriptInterface(handler, "callAndroid");
    }
}
