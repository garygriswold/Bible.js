package com.shortsands.audioplayer;

/**
 * Created by garygriswold on 8/30/17.
 */
import android.content.Context;
import android.util.Log;
import java.util.HashMap;
import org.json.JSONException;
import org.json.JSONArray;
import org.json.JSONObject;

public class MetaDataReader {

    private static String TAG = "MetaDataReader";

    private Context context;
    private HashMap<String, TOCAudioBible> metaData;
    private TOCAudioChapter metaDataVerse;
    private CompletionHandler readCompletion;
    private CompletionHandler readVerseCompletion;

    public MetaDataReader(Context context) {
        this.context = context;
        this.metaData = new HashMap<String, TOCAudioBible>();
    }

    //deinit {
    //    print("***** Deinit MetaDataReader *****")
    //}

    public void read(String languageCode, String mediaType, CompletionHandler completion) {
        this.readCompletion = completion;
        ReadResponseHandler handler = new ReadResponseHandler();
        AWSS3Cache cache = new AWSS3Cache(this.context, handler);
        String s3Bucket = "audio-us-west-2-shortsands";
        String s3Key = languageCode + "_" + mediaType + ".json";
        int expireInterval = 604800;
        cache.read(s3Bucket, s3Key, expireInterval);
    }

    class ReadResponseHandler implements CompletionHandler {

        public void completed(Object result, Object attachment) {
            Log.d(TAG, "***** Inside Completed in MetaDataReader");
            JSONArray json = parseJson(result);
            if (json != null) {
                Log.d(TAG, "JSON PARSED " + json.toString());
                for (int i=0; i<json.length(); i++) {
                    try {
                        JSONObject item = json.getJSONObject(i);
                        TOCAudioBible metaItem = new TOCAudioBible(item);
                        Log.d(TAG, "TOCAudioBible item: " + metaItem.toString());
                        metaData.put(metaItem.damId, metaItem);
                    } catch(JSONException je) {
                        Log.e(TAG, "Could not parse Audio Meta Data " + je.toString());
                        readCompletion.failed(je, attachment);
                    }
                }
                readCompletion.completed(metaData, attachment);
            } else {
                Log.d(TAG, "Not parsable JSON");
                readCompletion.failed(new RuntimeException("Could not parse JSON"), attachment);
            }
        }
        public void failed(Throwable exception, Object attachment) {
            Log.e(TAG, "Exception in MetaDataReader.read " + exception.toString());
            readCompletion.failed(exception, attachment);
        }
    }

    public void readVerseAudio(String damid, String sequence, String bookId, String chapter,
                               CompletionHandler completion) {
        this.readVerseCompletion = completion;
        ReadVerseResponseHandler handler = new ReadVerseResponseHandler();
        AWSS3Cache cache = new AWSS3Cache(this.context, handler);
        String s3Bucket = "audio-us-west-2-shortsands";
        String s3Key = damid + "_" + sequence + "_" + bookId + "_" + chapter + "_verse.json";
        int expireInterval = 604800;
        cache.read(s3Bucket, s3Key, expireInterval);
    }

    class ReadVerseResponseHandler implements CompletionHandler {

        public void completed(Object result, Object attachment) {
            JSONArray json = parseJson(result);
            if (json != null) {
                metaDataVerse = new TOCAudioChapter(json);
                readVerseCompletion.completed(metaDataVerse, this);
            } else {
                readVerseCompletion.failed(new RuntimeException("Failed to parse JSON"), this);
            }
        }
        public void failed(Throwable exception, Object attachment) {
            Log.e(TAG, "Exception in MetaDataReader.readVerseAudio " + exception.toString());
            readVerseCompletion.failed(exception, attachment);
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
