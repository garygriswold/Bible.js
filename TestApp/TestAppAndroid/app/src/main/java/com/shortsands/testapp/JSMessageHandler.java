package com.shortsands.testapp;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.res.Resources;
import android.os.Bundle;
import android.provider.Settings;
import android.view.inputmethod.InputMethodManager;
import android.view.View;
import android.util.Log;
import android.webkit.JavascriptInterface;
import android.webkit.ValueCallback;
import com.shortsands.audioplayer.AudioBibleController;
import com.shortsands.aws.AwsS3;
import com.shortsands.aws.AwsS3Manager;
import com.shortsands.aws.CompletionHandler;
import com.shortsands.aws.DownloadZipFileListener;
import com.shortsands.utility.Sqlite3;
import com.shortsands.videoplayer.VideoActivity;
import java.io.File;
import java.util.ArrayList;
import java.util.Locale;
import org.json.JSONArray;

/**
 * Created by garygriswold on 5/10/18.
 */

public class JSMessageHandler {

    private static final String TAG = "JSMessageHandler";
    private static final int ACTIVITY_CODE_PLAY_VIDEO = 7;
    private MainActivity activity;
    // Transient
    private String currVideoCallbackId;
    private String currVideoMethod;

    public JSMessageHandler(MainActivity activity) {
        this.activity = activity;
    }

    /**
     *
     */
    @JavascriptInterface
    public void jsHandler(String callbackId, String plugin, String method, JSONArray parameters) {
        Log.d(TAG, "Plugin " + plugin);
        if (plugin.equals("Utility")) {
            utilityPlugin(callbackId, "Utility." + method, parameters);
        } else if (plugin.equals("Sqlite")) {
            sqlitePlugin(callbackId, "Sqlite." + method, parameters);
        } else if (plugin.equals("AWS")) {
            awsPlugin(callbackId, "AWS." + method, parameters);
        } else if (plugin.equals("AudioPlayer")) {
            audioPlayerPlugin(callbackId, "AudioPlayer." + method, parameters);
        } else if (plugin.equals("VideoPlayer")) {
            videoPlayerPlugin(callbackId, "VideoPlayer." + method, parameters);
        } else {
            jsError(callbackId, method, "Unknown plugin");
        }
    }

    private void utilityPlugin(String callbackId, String method, JSONArray parameters) {
        if (method.equals("Utility.locale")) {
            JSONArray result = new JSONArray();
            Locale locale = Locale.getDefault();
            result.put(locale.toString());
            result.put(locale.getLanguage());
            result.put(locale.getScript());
            result.put(locale.getCountry());
            Log.d(TAG, "locale " + locale.toString());
            jsSuccess(callbackId, result);

        } else if (method.equals("Utility.platform")) {
            jsSuccess(callbackId, "Android");

        } else if (method.equals("Utility.modelType")) {
            jsSuccess(callbackId, android.os.Build.BRAND);

        } else if (method.equals("Utility.modelName")) {
            jsSuccess(callbackId, android.os.Build.MODEL);

        //} else if (method.equals("Utility.deviceSize")) {
        //    String deviceSize = DeviceSettings.deviceSize();
        //    jsSuccess(callbackId, deviceSize);

        } else if (method.equals("Utility.hideKeyboard")) {
            try {
                InputMethodManager inputManager = (InputMethodManager)this.activity.getSystemService(Context.INPUT_METHOD_SERVICE);
                View v = this.activity.getCurrentFocus();
                if (v != null) {
                    inputManager.hideSoftInputFromWindow(v.getWindowToken(), InputMethodManager.HIDE_NOT_ALWAYS);
                    jsSuccess(callbackId, true);
                } else {
                    jsError(callbackId, method, "No current focus");
                }
            } catch (Exception error) {
                jsError(callbackId, method, error.toString() + " on hideKeyboard");
            }

        } else {
            jsError(callbackId, method, "unknown method");
        }
    }

    private void sqlitePlugin(String callbackId, String method, JSONArray parameters) {

        if (method.equals("Sqlite.openDB")) {
            if (parameters.length() == 2) {
                try {
                    String dbname = parameters.getString(0);
                    boolean copyIfAbsent = parameters.getBoolean(1);
                    Sqlite3.openDB(this.activity, dbname, copyIfAbsent);
                    jsSuccess(callbackId);
                } catch(Exception err) {
                    jsError(callbackId, method, err.toString());
                }
            } else {
                jsError(callbackId, method, "Must have two parameters");
            }

        } else if (method.equals("Sqlite.queryJS")) {
            if (parameters.length() == 3) {
                try {
                    String dbname = parameters.getString(0);
                    String statement = parameters.getString(1);
                    JSONArray values = parameters.getJSONArray(2);
                    Sqlite3 db = Sqlite3.findDB(dbname);
                    JSONArray result = db.queryJS(statement, values);
                    jsSuccess(callbackId, result);
                } catch(Exception err) {
                    jsError(callbackId, method, err.toString(), new JSONArray());
                }
            } else {
                jsError(callbackId, method, "must have three parameters", new JSONArray());
            }

        } else if (method.equals("Sqlite.executeJS")) {
            if (parameters.length() == 3) {
                try {
                    String dbname = parameters.getString(0);
                    String statement = parameters.getString(1);
                    JSONArray values = parameters.getJSONArray(2);
                    Sqlite3 db = Sqlite3.findDB(dbname);
                    int result = db.executeJS(statement, values);
                    jsSuccess(callbackId, result);
                } catch(Exception err) {
                    jsError(callbackId, method, err.toString(), 0);
                }
            } else {
                jsError(callbackId, method, "must have three parameters", 0);
            }

        } else if (method.equals("Sqlite.bulkExecuteJS")) {
            if (parameters.length() == 3) {
                try {
                    String dbname = parameters.getString(0);
                    String statement = parameters.getString(1);
                    JSONArray values = parameters.getJSONArray(2);
                    Sqlite3 db = Sqlite3.findDB(dbname);
                    int result = db.bulkExecuteJS(statement, values);
                    jsSuccess(callbackId, result);
                } catch(Exception err) {
                    jsError(callbackId, method, err.toString(), 0);
                }
            } else {
                jsError(callbackId, method, "must have three parameters", 0);
            }

        } else if (method.equals("Sqlite.closeDB")) {
            if (parameters.length() == 1) {
                try {
                    String dbname = parameters.getString(0);
                    Sqlite3.closeDB(dbname);
                    jsSuccess(callbackId);
                } catch(Exception err) {
                    jsError(callbackId, method, err.toString());
                }
            } else {
                jsError(callbackId, method, "must have one parameter");
            }

        } else if (method.equals("Sqlite.listDB")) {
            try {
                ArrayList<String> files = Sqlite3.listDB(this.activity);
                JSONArray result = new JSONArray(files);
                jsSuccess(callbackId, result);
            } catch(Exception err) {
                jsError(callbackId, method, err.toString(), new JSONArray());
            }

        } else if (method.equals("Sqlite.deleteDB")) {
            if (parameters.length() == 1) {
                try {
                    String dbname = parameters.getString(0);
                    Sqlite3.deleteDB(this.activity, dbname);
                    jsSuccess(callbackId);
                } catch(Exception err) {
                    jsError(callbackId, method, err.toString());
                }
            } else {
                jsError(callbackId, method, "must have one parameter");
            }

        } else {
            jsError(callbackId, method, "unknown method");
        }
    }

    private void awsPlugin(String callbackId, String method, JSONArray parameters) {

        if (method.equals("AWS.downloadZipFile")) {
            if (parameters.length() == 4) {
                try {
                    String regionType = parameters.getString(0);
                    String s3Bucket = parameters.getString(1);
                    String s3Key = parameters.getString(2);
                    String filePath = parameters.getString(3);
                    File file = new File(this.activity.getDataDir(), filePath);
                    AwsS3 s3 = null;
                    if (regionType.equals("SS")) {
                        s3 = AwsS3Manager.findSS();
                    } else if (regionType.equals("DBP")) {
                        s3 = AwsS3Manager.findDbp();
                    } else if (regionType.equals("TEST")) {
                        s3 = AwsS3Manager.findTest();
                    } else {
                        jsError(callbackId, method, "Region must be SS, DBP, or TEST");
                    }
                    if (s3 != null) {
                        DownloadPluginZipFileListener listener = new DownloadPluginZipFileListener(this, callbackId, method);
                        listener.setActivity(this.activity); // presents ProgressCircle
                        s3.downloadZipFile(s3Bucket, s3Key, file, listener);

                        /*, complete: { err in
                            if let err1 = err {
                                self.jsError(callbackId, method, err1.toString());
                            } else {
                                self.jsSuccess(callbackId);
                            }
                        })*/
                    }
                } catch(Exception err) {
                    jsError(callbackId, method, err.toString());
                }
            } else {
                jsError(callbackId, method, "must have three parameters");
            }

        } else {
            jsError(callbackId, method, "unknown method");
        }
    }

    class DownloadPluginZipFileListener extends DownloadZipFileListener {

        //private static String TAG = "DownloadPluginZipFileListener";
        private JSMessageHandler jsMessageHandler;
        private String callbackId;
        private String method;

        private File unzipped = null;

        public DownloadPluginZipFileListener(JSMessageHandler jsMessageHandler, String callbackId, String method) {
            super();
            this.jsMessageHandler = jsMessageHandler;
            this.callbackId = callbackId;
            this.method = method;
        }

        @Override
        protected void onComplete(int id) {
            super.onComplete(id);
            this.jsMessageHandler.jsSuccess(this.callbackId);
            //this.callbackContext.success();
        }

        @Override
        public void onError(int id, Exception error) {
            super.onError(id, error);
            //this.callbackContext.error(error.toString() + " on " + this.file.getAbsolutePath());
            this.jsMessageHandler.jsError(this.callbackId, this.method, error.toString() + " on " + file.getAbsolutePath());
        }
    }

    private void audioPlayerPlugin(String callbackId, String method, JSONArray parameters) {

        if (method.equals("AudioPlayer.findAudioVersion")) {
            if (parameters.length() == 2) {
                try {
                    String version = parameters.getString(0);
                    String silLang = parameters.getString(1);
                    AudioBibleController audioController = AudioBibleController.shared(this.activity);
                    String bookList = audioController.findAudioVersion(version, silLang);
                    jsSuccess(callbackId, bookList);
                } catch(Exception err) {
                    jsError(callbackId, method, err.toString());
                }
            } else {
                jsError(callbackId, method, "must have two parameters", "");
            }

        } else if (method.equals("AudioPlayer.isPlaying")) {
            AudioBibleController audioController = AudioBibleController.shared(this.activity);
            String result = (audioController.isPlaying()) ? "T" : "F";
            jsSuccess(callbackId, result);

        } else if (method.equals("AudioPlayer.present")) {
            if (parameters.length() == 2) {
                try {
                    String book = parameters.getString(0);
                    int chapter = parameters.getInt(1);
                    AudioBibleController audioController = AudioBibleController.shared(this.activity);
                    AudioPresentCompletion complete = new AudioPresentCompletion(callbackId, method);
                    audioController.present(this.activity.getWebview(), book, chapter, complete);
                } catch(Exception err) {
                    jsError(callbackId, method, err.toString());
                }
            } else {
                jsError(callbackId, method, "must have two parameters");
            }

        } else if (method.equals("AudioPlayer.stop")) {
            AudioBibleController audioController = AudioBibleController.shared(this.activity);
            audioController.stop();
            jsSuccess(callbackId);

        } else {
            jsError(callbackId, method, "unknown method");
        }
    }

    class AudioPresentCompletion implements CompletionHandler {
        private String callbackId;
        private String method;

        public AudioPresentCompletion(String callbackId, String method) {
            this.callbackId = callbackId;
            this.method = method;
        }
        @Override
        public void completed(Object result) {
            //callbackContext.success("");
            jsSuccess(this.callbackId);
        }
        @Override
        public void failed(Throwable exception) {
            Log.d(TAG, "NextReadFile Failed " + exception.toString());
            //callbackContext.error(exception.toString());
            jsError(this.callbackId, this.method, exception.toString());
        }
    }

    private void videoPlayerPlugin(final String callbackId, final String method, final JSONArray parameters) {
        this.currVideoCallbackId = callbackId;
        this.currVideoMethod = method;

        if (method.equals("VideoPlayer.showVideo")) {
            if (parameters.length() == 5) {
                this.activity.runOnUiThread(new Runnable() {
                    public void run() {
                        final Intent videoIntent = new Intent(activity.getApplicationContext(), VideoActivity.class);
                        Bundle extras = new Bundle();
                        try {
                            extras.putString("mediaSource", parameters.getString(0));
                            extras.putString("videoId", parameters.getString(1));
                            extras.putString("languageId", parameters.getString(2));
                            extras.putString("silLang", parameters.getString(3));
                            extras.putString("videoUrl", parameters.getString(4));
                            videoIntent.putExtras(extras);
                            //cordova.startActivityForResult(plugin, videoIntent, ACTIVITY_CODE_PLAY_VIDEO);
                            activity.startActivityForResult(videoIntent, ACTIVITY_CODE_PLAY_VIDEO);
                        } catch(Exception err) {
                            jsError(callbackId, method, err.toString());
                        }
                    }
                });
            } else {
                jsError(callbackId, method, "must have five parameters");
            }

        } else {
            jsError(callbackId, method, "unknown method");
        }
    }

    //@Override This really belongs on VideoActivity, but how does it get JSMessageHandler
    public void onActivityResult(int requestCode, int resultCode, Intent intent) {
        Log.d(TAG, "onActivityResult: " + requestCode + " " + resultCode + " " + System.currentTimeMillis());

        if (ACTIVITY_CODE_PLAY_VIDEO == requestCode) {
            if (Activity.RESULT_OK == resultCode) {
                //this.callbackContext.success();
                jsSuccess(this.currVideoCallbackId);
            } else if (Activity.RESULT_CANCELED == resultCode) {
                String errMsg = "Error";
                if (intent != null && intent.hasExtra("message")) {
                    errMsg = intent.getStringExtra("message");
                }
                //this.callbackContext.error(errMsg);
                jsError(this.currVideoCallbackId, this.currVideoMethod, errMsg);
            }
        }
    }

    /**
    * Success Callbacks
    */
    private void jsSuccess(String callbackId) {
        jsCallback(callbackId, false, null, "null");
    }

    private void jsSuccess(String callbackId, int response) {
        jsCallback(callbackId, false, null, String.valueOf(response));
    }

    private void jsSuccess(String callbackId, boolean response) {
        jsCallback(callbackId, false, null, String.valueOf(response));
    }

    private void jsSuccess(String callbackId, String response) {
        String result = (response != null) ? "'" + response + "'" : "null";
        jsCallback(callbackId, false, null, result);
    }

    private void jsSuccess(String callbackId, JSONArray response) {
        String result = "'" + response.toString() + "'";
        jsCallback(callbackId, true, null, result);
    }

    /**
    * Error Callbacks
    */
    private void jsError(String callbackId, String method, String error) {
        String err = logError(method, error);
        jsCallback(callbackId, false, err, "null");
    }

    private void jsError(String callbackId, String method, String error, boolean defaultVal) {
        String err = logError(method, error);
        jsCallback(callbackId, false, err, String.valueOf(defaultVal));
    }

    private void jsError(String callbackId, String method, String error, int defaultVal) {
        String err = logError(method, error);
        jsCallback(callbackId, false, err, String.valueOf(defaultVal));
    }

    private void jsError(String callbackId, String method, String error, String defaultVal) {
        String err = logError(method, error);
        String response = "'" + defaultVal + "'";
        jsCallback(callbackId, false, err, response);
    }

    private void jsError(String callbackId, String method, String error, JSONArray defaultVal) {
        String err = logError(method, error);
        String response = "'" + defaultVal.toString() + "'";
        jsCallback(callbackId, true, err, response);
    }

    private void jsCallback(String callbackId, boolean json, String error, Object response) {
        int isJson = (json) ? 1 : 0;
        String err = (error != null) ? "'" + error + "'" : "null";
        final String message = "handleNative('" + callbackId + "', " + isJson + ", " + err + ", " + response + ");";
        Log.d(TAG, "RETURN TO JS: " + message);
        this.activity.runOnUiThread(new Runnable() {
            public void run() {
                activity.getWebview().evaluateJavascript(message, new ValueCallback<String>() {
                    @Override
                    public void onReceiveValue(String str) {
                        Log.d("jsCallbackError", str);
                    }
                });
            }
        });
    }

    private String logError(String method, String message) {
        String error = "PLUGIN ERROR: " + method + ": " + message;
        Log.e(TAG, error);
        return error;
    }
}

