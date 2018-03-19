package com.shortsands.audioplayer;

import android.content.Context;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager.NameNotFoundException;
import android.os.Build;
import android.util.Log;

import com.shortsands.aws.AwsS3;
import com.shortsands.aws.UploadDataListener;

import org.json.JSONException;
import org.json.JSONObject;

import java.text.DateFormat;
import java.text.SimpleDateFormat;

import java.util.Date;
import java.util.Locale;
import java.util.TimeZone;

/**
 * Created by garygriswold on 8/30/17.
 */


public class AudioAnalytics {
    private static String TAG = "VideoAnalytics";
    private static DateFormat isoFormat = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'"); // Quoted "Z" to indicate UTC, no timezone offset

    private Context context;
    private String mediaSource;
    private String mediaId;
    private String languageId;
    private String textVersion;
    private String silLang;
    private String sessionId;

    // Pass following from play to playEnd
    private Date timeStarted;
    private long startingPosition;

    AudioAnalytics(Context context,
                   String mediaSource,
                   String mediaId,
                   String languageId,
                   String textVersion,
                   String silLang) {
        this.context = context;
        this.mediaSource = mediaSource;
        this.mediaId = mediaId;
        this.languageId = languageId;
        this.textVersion = textVersion;
        this.silLang = silLang;

        AudioAnalyticsSessionId analyticsSessionId = new AudioAnalyticsSessionId(context);
        this.sessionId = analyticsSessionId.getSessionId();

        this.startingPosition = 0L;

        TimeZone tz = TimeZone.getTimeZone("UTC"); //should this be default, or local to user
        isoFormat.setTimeZone(tz);
    }

    void playStarted(String item, long position) {
        JSONObject dictionary = new JSONObject();
        try {
            dictionary.put("sessionId", this.sessionId);
            dictionary.put("mediaSource", this.mediaSource);
            dictionary.put("mediaId", this.mediaId);
            dictionary.put("languageId", this.languageId);
            dictionary.put("silLang", this.silLang);

            Locale locale = Locale.getDefault();
            dictionary.put("language", locale.getLanguage());
            dictionary.put("country", locale.getCountry());
            dictionary.put("locale", locale.toString());

            dictionary.put("deviceType", "mobile");
            dictionary.put("deviceFamily", Build.MANUFACTURER);
            dictionary.put("deviceName", Build.MODEL);
            dictionary.put("deviceOS", "android");
            dictionary.put("osVersion", Build.VERSION.RELEASE);
            try {
                PackageInfo pInfo = this.context.getPackageManager().getPackageInfo(this.context.getPackageName(), 0);
                dictionary.put("appVersion", pInfo.versionName);
                dictionary.put("appName", pInfo.packageName);
            } catch(NameNotFoundException nnfe) {
                dictionary.put("appVersion", nnfe.toString());
                dictionary.put("appName", "");
            }
            this.timeStarted = new Date();
            String timeStartedStr = isoFormat.format(this.timeStarted);
            dictionary.put("timeStarted", timeStartedStr);
            dictionary.put("isStreaming", "true");
            this.startingPosition = position;
            dictionary.put("startingItem", item);
            dictionary.put("startingPosition", Double.toString(this.startingPosition / 1000.0));

            Log.d(TAG, "BEGIN " + dictionary.toString());

            UploadDataListener listener = new UploadDataListener();
            AwsS3.shared().uploadAnalytics(this.sessionId, timeStartedStr + "-B", "AudioBegV1", dictionary.toString(2), listener);
        } catch(JSONException ex) {
            Log.e(TAG, "Error building Analytics Begin " + ex.toString());
        }
    }

    void playEnded(String item, long position) {
        Log.d(TAG, "INSIDE PLAY END ");
        JSONObject dictionary = new JSONObject();
        try {
            dictionary.put("sessionId", this.sessionId);
            dictionary.put("timeStarted", isoFormat.format(this.timeStarted));
            Date timeCompleted = new Date();
            String timeCompletedStr = isoFormat.format(timeCompleted);
            dictionary.put("timeCompleted", timeCompletedStr);
            long duration = (timeCompleted.getTime() - this.timeStarted.getTime());
            dictionary.put("elapsedTime", Double.toString(duration / 1000.0));
            // To compute media view, I would need to sum the times of all of the completed audios
            dictionary.put("endingItem", item);
            dictionary.put("endingPosition", Double.toString(position / 1000.0));

            Log.d(TAG, "END " + dictionary.toString());

            UploadDataListener listener = new UploadDataListener();
            AwsS3.shared().uploadAnalytics(this.sessionId, timeCompletedStr + "-E", "AudioEndV1", dictionary.toString(2), listener);
        } catch(JSONException ex) {
            Log.e(TAG, "Error building Analytics End " + ex.toString());
        }
    }
}

/*
{"AudioBegV1": {
  "sessionId" : "2BF8FFC3-35F7-4238-8800-DB8FA9058FFB",
  "mediaSource" : "FCBH",
  "language" : "en",
  "mediaId" : "DEMO",
  "languageId" : "ENG",
  "silLang" : "User's text lang setting",
  "language" : "en",
  "country" : "US",
  "locale" : "en_US",
  "deviceType" : "mobile",
  "deviceFamily" : "Apple",
  "deviceName" : "iPhone",
  "deviceOS" : "ios",
  "osVersion" : "11.0",
  "appName" : "com.shortsands.AudioPlayer",
  "appVersion" : "1.0",
  "timeStarted" : "2017-09-29T19:43:23Z",
  "isStreaming" : "true",
  "startingItem" : "DEMO_01_TST_001.mp3",
  "startingPosition" : "0.0"
}}

{"AudioEndV1": {
  "timeStarted" : "2017-09-29T19:43:23Z",
  "elapsedTime" : "7.193",
  "sessionId" : "2BF8FFC3-35F7-4238-8800-DB8FA9058FFB",
  "timeCompleted" : "2017-09-29T19:43:30Z",
  "endingItem" : "DEMO_01_TST_001.mp3",
  "endingPosition" : "5.037"
}}
 */
