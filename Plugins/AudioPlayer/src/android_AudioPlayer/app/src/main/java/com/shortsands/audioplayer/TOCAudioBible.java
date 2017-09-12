package com.shortsands.audioplayer;

/**
 * Created by garygriswold on 8/30/17.
 */
import android.util.Log;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.HashMap;

public class TOCAudioBible {

    private static String TAG = "TOCAudioBible";

    public String damId;
    public String languageCode;
    public String mediaType;
    public String versionCode;
    public String versionName;
    public String versionEnglish;
    public String collectionCode;
    public HashMap<String, TOCAudioBook> booksById;
    public HashMap<Integer, TOCAudioBook> booksBySeq;

    public TOCAudioBible(JSONObject jsonObject) {
        this.booksById = new HashMap<String, TOCAudioBook>();
        this.booksBySeq = new HashMap<Integer, TOCAudioBook>();
        try { this.damId = jsonObject.getString("dam_id"); } catch (JSONException je) { this.damId = ""; }
        try { this.languageCode = jsonObject.getString("language_code"); } catch (JSONException je) { this.languageCode = ""; } // Not attr damid
        try { this.mediaType = jsonObject.getString("media"); } catch (JSONException je) { this.mediaType = ""; }// Not an attr of damid
        try { this.versionCode = jsonObject.getString("version_code"); } catch (JSONException je) { this.versionCode = ""; }
        try { this.versionName = jsonObject.getString("version_name"); } catch (JSONException je) { this.versionName = ""; }
        try { this.versionEnglish = jsonObject.getString("version_english"); } catch (JSONException je) { this.versionEnglish = ""; }
        try { this.collectionCode = jsonObject.getString("collection_code"); } catch (JSONException je) { this.collectionCode = ""; }
        try {
            JSONArray books = jsonObject.getJSONArray("books");
                for (int i=0; i<books.length(); i++) {
                    JSONObject jsonBook = books.getJSONObject(i);
                    TOCAudioBook book = new TOCAudioBook(jsonBook);
                    Log.d(TAG, "BOOK " + book.toString());
                    this.booksById.put(book.bookId, book);
                    this.booksBySeq.put(book.sequenceNum, book);
                }
        } catch(JSONException je) {
            Log.e(TAG, "Could not determine type of JSON Object in MetaDataItem");
        }
    }

    public Reference nextChapter(Reference ref) {
        if (this.booksById.containsKey(ref.book)) {
            TOCAudioBook book = this.booksById.get(ref.book);
            if (ref.chapterNum() < book.numberOfChapters) {
                int next = ref.chapterNum() + 1;
                String nextStr = String.valueOf(next);
                switch(nextStr.length()) {
                    case 1: return new Reference(ref.damId, ref.sequence, ref.book, "00" + nextStr, ref.fileType);
                    case 2: return new Reference(ref.damId, ref.sequence, ref.book, "0" + nextStr, ref.fileType);
                    default: return new Reference(ref.damId, ref.sequence, ref.book, nextStr, ref.fileType);
                }
            } else {
                if (this.booksBySeq.containsKey(ref.sequenceNum() + 1)) {
                    TOCAudioBook nextBook = this.booksBySeq.get(ref.sequenceNum() + 1);
                    return new Reference(ref.damId, nextBook.sequence, nextBook.bookId, "001", ref.fileType);
                }
            }
        }
        return null;
    }

    public String toString() {
        StringBuilder str = new StringBuilder();
        str.append("damId=");
        str.append(this.damId);
        str.append("\n languageCode=");
        str.append(this.languageCode);
        str.append("\n mediaType=");
        str.append(this.mediaType);
        str.append("\n versionCode=");
        str.append(this.versionCode);
        str.append("\n versionName=");
        str.append(this.versionName);
        str.append("\n versionEnglish=");
        str.append(this.versionEnglish);
        str.append("\n collectionCode=");
        str.append(this.collectionCode);
        return str.toString();
    }
}
