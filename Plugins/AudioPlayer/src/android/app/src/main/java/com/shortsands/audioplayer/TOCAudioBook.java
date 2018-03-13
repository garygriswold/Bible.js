package com.shortsands.audioplayer;

import android.util.Log;

import org.json.JSONException;
import org.json.JSONObject;

/**
 * Created by garygriswold on 8/30/17.
 */

class TOCAudioBook {

    private static final String TAG = "TOCAudioBook";

    final String bookId;
    final String sequence;
    final int sequenceNum;
    final String bookName;
    final int numberOfChapters;

    TOCAudioBook(JSONObject jsonBook) {
        String temp;
        try { temp = jsonBook.getString("book_id"); } catch (JSONException je) { temp = ""; }
        this.bookId = temp;
        try { temp = jsonBook.getString("sequence"); } catch (JSONException je) { temp = "000"; }
        this.sequence = temp;
        this.sequenceNum = Integer.parseInt(this.sequence);
        try { temp = jsonBook.getString("book_name"); } catch(JSONException je) { temp = ""; }
        this.bookName = temp;
        try { temp = jsonBook.getString("number_of_chapters"); } catch(JSONException je) { temp = "0"; }
        this.numberOfChapters = Integer.parseInt(temp);
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
