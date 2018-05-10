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
        //setContentView(R.layout.activity_main);

        WebView webview = new WebView(this);
        setContentView(webview);
        //webview.loadUrl("http://shortsands.com/");
        webview.loadUrl("file:///android_asset/www/index.html");
    }
}
