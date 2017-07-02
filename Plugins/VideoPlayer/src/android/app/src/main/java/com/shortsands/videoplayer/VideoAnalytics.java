package com.shortsands.videoplayer;

import android.content.Context;
import android.os.Build;
import android.util.Log;

import com.shortsands.aws.AwsS3;
import com.shortsands.aws.UploadDataListener;
import com.shortsands.aws.BuildConfig;

import org.json.JSONException;
import org.json.JSONObject;

import java.text.DateFormat;
import java.text.SimpleDateFormat;

import java.util.Date;
import java.util.Locale;
import java.util.TimeZone;
/**
*  VideoAnalytics.java
*  AnalyticsProto
*
*  Created by Gary Griswold on 6/29/17.
*  Copyright © 2017 ShortSands. All rights reserved.
*/
class VideoAnalytics {

    private static String TAG = "VideoAnalytics";
    private static String APP_NAME = "ShortSandsBible";

    private static DateFormat isoFormat = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'"); // Quoted "Z" to indicate UTC, no timezone offset
    
    private String mediaSource;
    private String mediaId;
    private String languageId;
    private String silLang;
    private String sessionId;
    
    // Pass following from play to playEnd
    private Date timeStarted;
    private long mediaViewStartingPosition;

    VideoAnalytics(Context context,
                   String mediaSource,
                   String mediaId,
                   String languageId,
                   String silLang) {
        
        this.mediaSource = mediaSource;
        this.mediaId = mediaId;
        this.languageId = languageId;
        this.silLang = silLang;
        
        AnalyticsSessionId analyticsSessionId = new AnalyticsSessionId(context);
        this.sessionId = analyticsSessionId.getSessionId();
        
        //this.timeStarted = new Date();
        this.mediaViewStartingPosition = 0L;

        TimeZone tz = TimeZone.getTimeZone("UTC");
        //TimeZone tz = TimeZone.getDefault();
        isoFormat.setTimeZone(tz);
    }
    
    void playStarted(long position) {
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
            dictionary.put("appName", VideoAnalytics.APP_NAME);

            dictionary.put("appVersion", BuildConfig.VERSION_CODE);

            this.timeStarted = new Date();
            String timeStartedStr = isoFormat.format(this.timeStarted);
            dictionary.put("timeStarted", timeStartedStr);

            dictionary.put("isStreaming", "true");
            this.mediaViewStartingPosition = position; /// Is this really seconds or ms
            dictionary.put("mediaViewStartingPosition", Long.toString(this.mediaViewStartingPosition));

            Log.d(TAG, "BEGIN " + dictionary.toString());

            UploadDataListener listener = new UploadDataListener();
            AwsS3.shared().uploadAnalytics(this.sessionId, timeStartedStr + "-B", "VideoBegV1", dictionary.toString(), listener);
        } catch(JSONException ex) {
            Log.e(TAG, "Error building Analytics Begin " + ex.toString());
        }
    }
    
    void playEnded(long position, boolean completed) {
        Log.d(TAG, "INSIDE PLAY END ");
        JSONObject dictionary = new JSONObject();
        try {
            dictionary.put("sessionId", this.sessionId);
            dictionary.put("timeStarted", isoFormat.format(this.timeStarted));
            Date timeCompleted = new Date();
            String timeCompletedStr = isoFormat.format(timeCompleted);
            dictionary.put("timeCompleted", timeCompletedStr);
            long duration = (timeCompleted.getTime() - this.timeStarted.getTime()) / 1000L;
            dictionary.put("elapsedTime", Long.toString(duration));
            long mediaTimeViewInSeconds = position - this.mediaViewStartingPosition;
            dictionary.put("mediaTimeViewInSeconds", Long.toString(mediaTimeViewInSeconds));
            dictionary.put("mediaViewCompleted", Boolean.toString(completed));

            Log.d(TAG, "END " + dictionary.toString());

            UploadDataListener listener = new UploadDataListener();
            AwsS3.shared().uploadAnalytics(this.sessionId, timeCompletedStr + "-E", "VideoEndV1", dictionary.toString(), listener);
        } catch(JSONException ex) {
            Log.e(TAG, "Error building Analytics End " + ex.toString());
        }
    }
}

