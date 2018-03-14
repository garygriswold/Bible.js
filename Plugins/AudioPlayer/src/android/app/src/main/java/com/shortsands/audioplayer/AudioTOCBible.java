package com.shortsands.audioplayer;

/**
 * Created by garygriswold on 8/30/17.
 */
import android.content.Context;
import android.util.Log;
import com.shortsands.aws.AwsS3Cache;
import com.shortsands.aws.CompletionHandler;
import java.util.HashMap;
import org.json.JSONException;
import org.json.JSONArray;
import org.json.JSONObject;

class AudioTOCBible {

    private static final String TAG = "MetaDataReader";

    private final Context context;
    private final HashMap<String, AudioTOCTestament> metaData;
    private AudioTOCChapter metaDataVerse;
    private CompletionHandler readCompletion;
    private CompletionHandler readVerseCompletion;

    AudioTOCBible(Context context) {
        this.context = context;
        this.metaData = new HashMap<String, AudioTOCTestament>();
    }

    void read(String languageCode, String mediaType, CompletionHandler completion) {
        this.readCompletion = completion;
        String s3Bucket = "audio-us-west-2-shortsands";
        String s3Key = languageCode + "_" + mediaType + ".json";
        int expireInterval = 604800; // seconds in 1 week
        ReadResponseHandler handler = new ReadResponseHandler();
        AwsS3Cache.shared().readText(s3Bucket, s3Key, expireInterval, handler);
    }

    class ReadResponseHandler implements CompletionHandler {

        public void completed(Object result) {
            Log.d(TAG, "***** Inside Completed in MetaDataReader");
            JSONArray json = parseJson(result);
            if (json != null) {
                Log.d(TAG, "JSON PARSED " + json.toString());
                for (int i=0; i<json.length(); i++) {
                    try {
                        JSONObject item = json.getJSONObject(i);
                        AudioTOCTestament metaItem = new AudioTOCTestament("FCBH", item);
                        Log.d(TAG, "TOCAudioBible item: " + metaItem.toString());
                        metaData.put(metaItem.damId, metaItem);
                    } catch(JSONException je) {
                        Log.e(TAG, "Could not parse Audio Meta Data " + je.toString());
                        readCompletion.failed(je);
                    }
                }
                readCompletion.completed(metaData);
            } else {
                Log.d(TAG, "Not parsable JSON");
                readCompletion.failed(new RuntimeException("Could not parse JSON"));
            }
        }
        public void failed(Throwable exception) {
            Log.e(TAG, "Exception in MetaDataReader.read " + exception.toString());
            readCompletion.failed(exception);
        }
    }

    void readVerseAudio(String damid, String sequence, String bookId, String chapter,
                               CompletionHandler completion) {
        this.readVerseCompletion = completion;
        String s3Bucket = "audio-us-west-2-shortsands";
        String s3Key = damid + "_" + sequence + "_" + bookId + "_" + chapter + "_verse.json";
        int expireInterval = 604800; // seconds in 1 week
        ReadVerseResponseHandler handler = new ReadVerseResponseHandler();
        AwsS3Cache.shared().readText(s3Bucket, s3Key, expireInterval, handler);
    }

    class ReadVerseResponseHandler implements CompletionHandler {

        public void completed(Object result) {
            JSONArray json = parseJson(result);
            if (json != null) {
                metaDataVerse = new AudioTOCChapter(json);
                readVerseCompletion.completed(metaDataVerse);
            } else {
                readVerseCompletion.failed(new RuntimeException("Failed to parse JSON"));
            }
        }
        public void failed(Throwable exception) {
            Log.e(TAG, "Exception in MetaDataReader.readVerseAudio " + exception.toString());
            readVerseCompletion.failed(exception);
        }
    }

    private JSONArray parseJson(Object data) {
        if (data != null) {
            if (data instanceof String) {
                try {
                    JSONArray json = new JSONArray((String) data);
                    return json;
                } catch(JSONException exc) {
                    Log.e(TAG, "Error parsing Meta Data json " + exc.toString());
                    return null;
                }
            } else {
                Log.e(TAG, "Downloaded Meta Data is not String.");
                return null;
            }
        } else {
            Log.e(TAG, "Download Meta Data Error.");
            return null;
        }
    }
}
