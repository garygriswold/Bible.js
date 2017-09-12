package com.shortsands.audioplayer;

import android.util.Log;

import org.json.JSONException;
import org.json.JSONObject;

/**
 * Created by garygriswold on 8/30/17.
 */

public class TOCAudioBook {

    private static String TAG = "TOCAudioBook";

    public String bookId;
    public String sequence;
    public int sequenceNum;
    public String bookName;
    public int numberOfChapters;

    public TOCAudioBook(JSONObject jsonBook) {
        try { this.bookId = jsonBook.getString("book_id"); } catch (JSONException je) { this.bookId = ""; }
        try { this.sequence = jsonBook.getString("sequence"); } catch (JSONException je) { this.sequence = "000"; }
        this.sequenceNum = Integer.parseInt(this.sequence);
        try { this.bookName = jsonBook.getString("book_name"); } catch(JSONException je) { this.bookName = ""; }
        String chapters;
        try { chapters = jsonBook.getString("number_of_chapters"); } catch(JSONException je) { chapters = "0"; }
        this.numberOfChapters = Integer.parseInt(chapters);
    }

    public String toString() {
        StringBuilder str = new StringBuilder();
        str.append("book_id=");
        str.append(this.bookId);
        str.append(", sequence=");
        str.append(this.sequence);
        str.append(", bookName=");
        str.append(this.bookName);
        str.append(", numberOfChapter=");
        str.append(this.numberOfChapters);
        return str.toString();
    }
}
