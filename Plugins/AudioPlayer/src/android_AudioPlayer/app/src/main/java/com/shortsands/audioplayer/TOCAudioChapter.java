package com.shortsands.audioplayer;

/**
 * Created by garygriswold on 8/30/17.
 */
import android.util.Log;
import java.util.ArrayList;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

class TOCAudioChapter {

    private static final String TAG = "TOCAudioChapter";

    final ArrayList<Double> versePositions;

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

    int findVerseByPosition(int priorVerse, int milliSeconds) {
        double seconds = milliSeconds / 1000.0;
        int index = (priorVerse > 0 && priorVerse < this.versePositions.size()) ? priorVerse : 1;
        double priorPosition = this.versePositions.get(index);
        if (seconds > priorPosition) {
            while(index < (this.versePositions.size() - 1)) {
                index += 1;
                double versePos = this.versePositions.get(index);
                if (seconds < versePos) {
                    return index - 1;
                }
            }
            return this.versePositions.size() - 1;

        } else if (seconds < priorPosition) {
            while(index > 2) {
                index -= 1;
                double versePos = this.versePositions.get(index);
                if (seconds >= versePos) {
                    return index;
                }
            }
            return 1;

        } else { // seconds == priorPosition
            return index;
        }
    }

    int findPositionOfVerse(int verse) {
        double seconds = (verse > 0 && verse < this.versePositions.size()) ? this.versePositions.get(verse) : 0.0;
        return (int)Math.round(seconds * 1000);
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
