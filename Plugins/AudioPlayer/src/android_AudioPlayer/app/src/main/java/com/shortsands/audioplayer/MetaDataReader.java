package com.shortsands.audioplayer;

/**
 * Created by garygriswold on 8/30/17.
 */
import android.content.Context;
import android.util.Log;
import java.util.HashMap;
import org.json.JSONException;
import org.json.JSONObject;

public class MetaDataReader implements CompletionHandler {

    private static String TAG = "MetaDataReader";

    private Context context;
    private HashMap<String, TOCAudioBible> metaData;
    private TOCAudioChapter metaDataVerse;

    public MetaDataReader(Context context) {
        this.context = context;
        this.metaData = new HashMap<String, TOCAudioBible>();
    }

    //deinit {
    //    print("***** Deinit MetaDataReader *****")
    //}

    public void read(String languageCode, String mediaType) {
              //readComplete: @escaping (_ metaData: Dictionary<String, TOCAudioBible>) -> Void) {
        AWSS3Cache cache = new AWSS3Cache(this.context, this);
        String s3Bucket = "audio-us-west-2-shortsands";
        String s3Key = languageCode + "_" + mediaType + ".json";
        int expireInterval = 604800;
        cache.read(s3Bucket, s3Key, expireInterval);
        //        getComplete: { data in
        //    let result = self.parseJson(data: data)
        //    if (result is Array<AnyObject>) {
        //        let array: Array<AnyObject> = result as! Array<AnyObject>
        //        for item in array {
        //            let metaItem = TOCAudioBible(jsonObject: item)
        //            print("\(metaItem.toString())")
        //            self.metaData[metaItem.damId] = metaItem
        //        }
        //    } else {
        //        print("Could not determine type of outer object in Meta Data")
        //    }
        //   readComplete(self.metaData)
        //})
    }

    public void readVerseAudio(String damid, String sequence, String bookId, String chapter) {
                        //readComplete: @escaping (_ audioVerse: TOCAudioChapter?) -> Void) {
        AWSS3Cache cache = new AWSS3Cache(this.context, this);
        String s3Bucket = "audio-us-west-2-shortsands";
        String s3Key = damid + "_" + sequence + "_" + bookId + "_" + chapter + "_verse.json";
        int expireInterval = 604800;
        cache.read(s3Bucket, s3Key, expireInterval);
        //        getComplete: { data in
        //    let result = self.parseJson(data: data)
        //    self.metaDataVerse = TOCAudioChapter(jsonObject: result)
        //    readComplete(self.metaDataVerse)
        //})
    }

    public void completed(Object result, Object attachment) {
        Log.d(TAG, "***** Inside Completed in MetaDataReader");
        JSONObject json = parseJson(result);
        if (json != null) {
            Log.d(TAG, "JSON PARSED " + json.toString());
            //    if (result is Array<AnyObject>) {
            //        let array: Array<AnyObject> = result as! Array<AnyObject>
            //        for item in array {
            //            let metaItem = TOCAudioBible(jsonObject: item)
            //            print("\(metaItem.toString())")
            //            self.metaData[metaItem.damId] = metaItem
            //        }
            //    } else {
            //        print("Could not determine type of outer object in Meta Data")
            //    }
            //   readComplete(self.metaData)
            //})
        }
    }
    public void failed(Throwable exception, Object attachment) {
        Log.d(TAG, "Exception in MetaDataReader " + exception.toString());
    }

    private JSONObject parseJson(Object data) {
        if (data != null) {
            if (data instanceof String) {
                try {
                    JSONObject json = new JSONObject((String) data);
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
