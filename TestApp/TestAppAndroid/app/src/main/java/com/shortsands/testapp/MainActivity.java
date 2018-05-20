package com.shortsands.testapp;

import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.webkit.ValueCallback;
import android.webkit.WebView;

/**
 * https://stackoverflow.com/questions/22895140/call-android-methods-from-javascript
 */

public class MainActivity extends AppCompatActivity {

    private WebView webView;

    public WebView getWebview() {
        return webView;
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        this.webView = new WebView(this);
        setContentView(this.webView);
        this.webView.loadUrl("file:///android_asset/www/index.html");

        this.webView.getSettings().setJavaScriptEnabled(true);
        JSMessageHandler handler = new JSMessageHandler(this);
        this.webView.addJavascriptInterface(handler, "callAndroid");
    }
}