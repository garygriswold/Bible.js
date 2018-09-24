package com.shortsands.audioplayer;

import android.database.Cursor;
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

    AudioTOCBook(AudioTOCTestament testament, Cursor cursor) {
        this.testament = testament;
        this.bookId = cursor.getString(0);
        this.bookOrder = cursor.getString(1);
        try {
            this.sequence = Integer.parseInt(this.bookOrder);
        } catch (Exception ex) {
            this.sequence = 0;
        }
        this.bookName = this.bookId; // Reset by MetaDataReader.readBookNames to bookName
        String chapters = cursor.getString(2);
        try {
            this.numberOfChapters = Integer.parseInt(chapters);
        } catch (Exception ex) {
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
