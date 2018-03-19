package com.shortsands.audioplayer;

import android.util.Log;

/**
 * Created by garygriswold on 8/30/17.
 */

class AudioTOCBook {

    private static final String TAG = "AudioTOCBook";

    AudioTOCTestament testament;
    String bookId;
    String bookOrder;
    Integer sequence;
    String bookName;  // Used by AudioControlCenter
    int numberOfChapters;

    AudioTOCBook(AudioTOCTestament testament, String[] dbRow) {
        this.testament = testament;
        this.bookId = dbRow[0];
        this.bookOrder = dbRow[1];
        try {
            this.sequence = Integer.parseInt(this.bookOrder);
        } catch (NumberFormatException ex) {
            this.sequence = 0;
        }
        this.bookName = this.bookId; // Reset by MetaDataReader.readBookNames to bookName
        String chapters = dbRow[2];
        try {
            this.numberOfChapters = Integer.parseInt(chapters);
        } catch (NumberFormatException ex) {
            this.numberOfChapters = 1;
        }
    }

    //deinit {
    //    print("***** Deinit AudioTOCBook *****")
    //}

    public String toString() {
        String str = "bookId=" + this.bookId +
                ", bookOrder=" + this.bookOrder +
                ", numberOfChapter=" + String.valueOf(this.numberOfChapters);
        return str;
    }

}
