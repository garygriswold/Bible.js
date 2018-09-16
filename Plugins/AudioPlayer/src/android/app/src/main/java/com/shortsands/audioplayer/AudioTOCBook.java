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
    String dbpBookName;
    String bookName;  // Localized Bookname from Bible, Used by AudioControlCenter
    int numberOfChapters;

    AudioTOCBook(AudioTOCTestament testament, int index, Cursor cursor) {
        this.testament = testament;
        this.bookId = cursor.getString(0);
        this.bookOrder = cursor.getString(1);
        this.sequence = index;
        this.dbpBookName = cursor.getString(2);
        this.bookName = this.bookId; // Reset by MetaDataReader.readBookNames to bookName
        String chapters = cursor.getString(3);
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
