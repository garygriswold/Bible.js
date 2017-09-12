package com.shortsands.audioplayer;

/**
 * Created by garygriswold on 8/30/17.
 */
import android.util.Log;
import java.util.ArrayList;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

public class TOCAudioChapter {

    private static String TAG = "TOCAudioChapter";

    public ArrayList<Double> versePositions;

    TOCAudioChapter(JSONArray jsonArray) {
        this.versePositions = new ArrayList<Double>();
        int lastItem = jsonArray.length() - 1;
        int lastVerseNum = 0;
        try {
            JSONObject lastVerse = jsonArray.getJSONObject(lastItem);
            lastVerseNum = lastVerse.getInt("verse_id");

        } catch(JSONException jexc) {
            lastVerseNum = 200;
        }
        for (int i=0; i<= lastVerseNum; i++) {
            this.versePositions.add(i, 0.0);
        }

        for (int i=0; i<jsonArray.length(); i++) {
            try {
                JSONObject item = jsonArray.getJSONObject(i);
                int verseId = item.getInt("verse_id");
                double position = item.getDouble("position");
                this.versePositions.set(verseId, position);

            } catch(JSONException jexc) {
                Log.e(TAG, "TOCAudioChapter could not parse item " + i);
            }
        }
    }

    //deinit {
    //    print("***** Deinit TOCAudioChapter *****")
    //}

    public double findVerseByPosition(double seconds) {
        for (int index=0; index<this.versePositions.size(); index++) {
            double versePos = this.versePositions.get(index);
            if (seconds == versePos) {
                return seconds;
            } else if (seconds < versePos) {
                return (index > 0) ? this.versePositions.get(index - 1) : 0.0;
            }
        }
        return (this.versePositions.size() > 0) ? this.versePositions.get(this.versePositions.size() - 1) : 0.0;
    }

    public String toString() {
        StringBuilder str = new StringBuilder();
        for (int i=0; i<this.versePositions.size(); i++) {
            double position = this.versePositions.get(i);
            str.append("verse_id=" + i + ", position=" + position + "\n");
        }
        return(str.toString());
    }
}
