package com.shortsands.testapp;

import android.content.Context;
import android.util.Log;
import android.webkit.JavascriptInterface;
import java.util.Locale;
import org.json.JSONArray;

/**
 * Created by garygriswold on 5/10/18.
 */

public class JSMessageHandler {

    private static String TAG = "JSMessageHandler";
    private MainActivity activity;

    public JSMessageHandler(MainActivity activity) {
        this.activity = activity;
    }

    /**
     *
     */
    @JavascriptInterface
    public void jsHandler(String plugin, String method, String handler) {//}, JSONArray parameters) {
        Log.d(TAG, "Plugin " + plugin);
        if (plugin.equals("Utility")) {
            utilityPlugin(method, handler);//, parameters);
        } else {
            Log.d(TAG, "Unknown plugin " + plugin);
            // Should I try to respond to this?
        }
    }

    private void utilityPlugin(String method, String handler) {//}, JSONArray parameters) {
        Log.d(TAG, "method " + method);
        if (method.equals("getLocale")) {
            String locale = Locale.getDefault().toString();
            locale = "es_X2";
            Log.d(TAG, "locale " + locale);
            String response = handler + "('" + locale + "');";
            this.activity.jsCallback(response);
        } else {
            Log.d(TAG, "Unknown method " + method + " in Plugin Utility");
        }
    }
}
