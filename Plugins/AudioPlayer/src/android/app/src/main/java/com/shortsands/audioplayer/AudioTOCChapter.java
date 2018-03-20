package com.shortsands.audioplayer;

/**
 * Created by garygriswold on 8/30/17.
 */
import android.util.Log;

class AudioTOCChapter {

    private static final String TAG = "AudioTOCChapter";

    private Double[] versePositions = new Double[0];

    AudioTOCChapter(String json) {
        String trimmed = json.substring(1, json.length() - 1);
        String[] parts = trimmed.split(",");
        this.versePositions = new Double[parts.length];
        this.versePositions[0] = 0.0;
        for (int i=1; i<parts.length; i++) {
            try {
                this.versePositions[i] = Double.parseDouble(parts[i]);
            } catch (Exception ex) {
                this.versePositions[i] = this.versePositions[i-1];
            }
        }
        Log.d(TAG, this.versePositions.toString());
    }

    //deinit {
    //    print("***** Deinit AudioTOCChapter *****")
    //}

    boolean hasPositions() {
        return versePositions.length > 0;
    }

    int findVerseByPosition(int priorVerse, int milliseconds) {
        double seconds = milliseconds / 1000.0;
        int index = (priorVerse > 0 && priorVerse < this.versePositions.length) ? priorVerse : 1;
        double priorPosition = this.versePositions[index];
        if (seconds > priorPosition) {
            int lastVerse = this.versePositions.length - 1;
            while(index++ < lastVerse) {
                if (seconds < this.versePositions[index]) {
                    return (index - 1);
                }
            }
            return (lastVerse);

        } else if (seconds < priorPosition) {
            while(index-- > 2) {
                if (seconds >= this.versePositions[index]) {
                    return index;
                }
            }
            return 1;

        } else { // seconds == priorPosition
            return index;
        }
    }

    int findPositionOfVerse(int verse)  {
        double seconds = (verse > 0 && verse < this.versePositions.length) ? this.versePositions[verse] : 0.0;
        //return CMTime(seconds: seconds, preferredTimescale: CMTimeScale(1000))
        return (int)Math.floor(seconds * 1000.0);
    }

    public String toString() {
        StringBuilder str = new StringBuilder();
        for (int i = 1; i < this.versePositions.length; i++) {
            double position = this.versePositions[i];
            str.append("verse_id=");
            str.append(String.valueOf(i));
            str.append(", position=");
            str.append(String.valueOf(position));
            str.append("\n");
        }
        return(str.toString());
    }
}
